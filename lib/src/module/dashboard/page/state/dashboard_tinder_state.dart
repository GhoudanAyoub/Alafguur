import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';

import '../../../../app/service/random_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/model/user_match_action_model.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../service/dashboard_tinder_service.dart';
import 'dashboard_state.dart';
import 'dashboard_user_state.dart';

part 'dashboard_tinder_state.g.dart';

typedef OnLikeClickedCallback = Function();
typedef OnSkipClickedCallback = Function();
typedef OnDislikeClickedCallback = Function();
typedef OnBackClickedCallback = Function();

class DashboardTinderState = _DashboardTinderState with _$DashboardTinderState;

abstract class _DashboardTinderState with Store {
  final RootState rootState;
  final DashboardUserState dashboardUserState;
  final DashboardTinderService dashboardTinderService;
  final DashboardState dashboardState;
  final RandomService randomService;

  late ReactionDisposer _lastChangedProfileWatcherCancellation;

  @observable
  bool isFiltersLoading = false;

  @observable
  bool isFilterSetup = false;

  @observable
  bool isCardMovingToLeft = false;

  @observable
  bool isCardMovingToRight = false;

  @observable
  bool isPreviewMode = false;

  @observable
  bool isDashboardLoaded = false;

  @observable
  bool isNoUsersDescriptionVisible = false;

  @observable
  List<UserModel> userList = [];

  @observable
  int activeUserIndex = 0;

  @observable
  UserPermissionModel? searchPermission;

  @observable
  UserPermissionModel? filtersPermission;

  OnLikeClickedCallback? _likeClickedCallback;
  OnSkipClickedCallback? _skipClickedCallback;
  OnDislikeClickedCallback? _dislikeClickedCallback;
  OnBackClickedCallback? _backClickedCallback;

  late ReactionDisposer _userLoadedUpdatesWatcherCancellation;
  late ReactionDisposer _userUpdatesWatcherCancellation;
  late ReactionDisposer _userLocationUpdatesWatcherCancellation;

  final String _makeSearchPermissionName = 'base_search_users';
  final String _useFiltersPermissionName = 'skmobileapp_tinder_filters';

  List<int?> _previousUserIdList = [];
  late Timer _autoSearchTimer;
  bool _isRequestStarted = false;
  int? _lastSkippedProfileId = 0;

  _DashboardTinderState({
    required this.rootState,
    required this.dashboardUserState,
    required this.dashboardTinderService,
    required this.dashboardState,
    required this.randomService,
  });

  /// pre initialize (watchers, etc)
  @action
  void init() {
    isFilterSetup = dashboardTinderService.isFilterSetup;
    userList = [];
    _previousUserIdList = [];
    _lastSkippedProfileId = 0;

    isDashboardLoaded = dashboardUserState.isUserLoaded;

    if (isDashboardLoaded) {
      // initial permissions initialization
      searchPermission =
          dashboardUserState.getUserPermission(_makeSearchPermissionName);

      filtersPermission =
          dashboardUserState.getUserPermission(_useFiltersPermissionName);

      if (_isUserSearchAllowed()) {
        _searchUsers();
      }
    }

    // init watchers
    _initUserLoadedUpdatesWatcher();
    _initUserUpdatesWatcher();
    _initUserLocationUpdatesWatcher();
    _initLastChangedProfileWatcher();

    // init auto search
    _initAutoSearch();
  }

  /// unsubscribe watchers and clean resources
  void dispose() {
    _userLoadedUpdatesWatcherCancellation();
    _userUpdatesWatcherCancellation();
    _userLocationUpdatesWatcherCancellation();
    _lastChangedProfileWatcherCancellation();

    _autoSearchTimer.cancel();
    _isRequestStarted = false;
  }

  void setLikeClickedCallback(
    OnLikeClickedCallback likeClickedCallback,
  ) {
    _likeClickedCallback = likeClickedCallback;
  }

  void setSkipClickedCallback(
    OnSkipClickedCallback skipClickedCallback,
  ) {
    _skipClickedCallback = skipClickedCallback;
  }

  void setDislikeClickedCallback(
    OnLikeClickedCallback dislikeClickedCallback,
  ) {
    _dislikeClickedCallback = dislikeClickedCallback;
  }

  void setBackClickedCallback(
    OnBackClickedCallback backClickedCallback,
  ) {
    _backClickedCallback = backClickedCallback;
  }

  bool get isLocationLoading => dashboardUserState.isUserLocationLoading;

  UserModel? get me => dashboardUserState.user;

  @action
  Future<void> initializeFilters(FormBuilderWidget formBuilder) async {
    isFiltersLoading = true;

    try {
      formBuilder.registerFormElements(
        await dashboardTinderService.getFormElements(
          rootState.getSiteSetting('defaultTinderFilterLocationMin', 0),
          rootState.getSiteSetting('defaultTinderFilterLocationMax', 0),
          rootState.getSiteSetting('defaultTinderFilterLocationStep', 0),
          rootState.getSiteSetting('defaultTinderFilterDistanceUnit', ''),
          rootState.getSiteSetting('defaultTinderFilterDefaultMinAge', 0),
          rootState.getSiteSetting('defaultTinderFilterDefaultMaxAge', 0),
        ),
      );
    } catch (error) {
      isFiltersLoading = false;

      throw error;
    }

    isFiltersLoading = false;
  }

  @action
  Future<void> clearFilter() async {
    await dashboardTinderService.clearFilter();
    isFilterSetup = false;
    removeProfiles(completeRemoving: true);
  }

  @action
  Future<void> saveFilter(List<FormElementModel?> filters) async {
    final Map filterList = {};

    filters.forEach(
      (element) => filterList[element!.key] = {
        'name': element.key,
        'value': element.value,
        'type': element.type,
      },
    );

    await dashboardTinderService.saveFilter(filterList);
    isFilterSetup = true;
    removeProfiles(completeRemoving: true);
  }

  @action
  void increaseUserIndex({
    MatchActionTypeEnum? matchAction,
  }) {
    // update the user's match action
    if (matchAction != null) {
      final clonedProfile = _cloneProfile(userList[activeUserIndex]);
      clonedProfile.matchAction = UserMatchActionModel(
        id: randomService.integer(),
        userId: userList[activeUserIndex].id!,
        type: matchAction == MatchActionTypeEnum.like
            ? MatchActionTypeEnum.like
            : MatchActionTypeEnum.dislike,
      );

      userList[activeUserIndex] = clonedProfile;
    }

    activeUserIndex++;

    // we have reached the end of users
    if (activeUserIndex == userList.length) {
      removeProfiles();
    }
  }

  @action
  void decreaseUserIndex() {
    if (activeUserIndex - 1 >= 0) {
      activeUserIndex--;
      _lastSkippedProfileId = 0;
    }
  }

  @action
  void likeProfile() {
    if (_likeClickedCallback != null) {
      _likeClickedCallback!();
    }
  }

  @action
  void dislikeProfile() {
    if (_dislikeClickedCallback != null) {
      _dislikeClickedCallback!();
    }
  }

  @action
  void backProfile() {
    if (_backClickedCallback != null) {
      _backClickedCallback!();
    }
  }

  @action
  void removeProfiles({
    completeRemoving = false,
  }) {
    // refresh the user list
    userList = [];

    if (completeRemoving) {
      _previousUserIdList = [];
    }

    // trying to find other users
    if (_isUserSearchAllowed()) {
      _searchUsers();
    }
  }

  @computed
  bool get isPageLoading {
    return !isDashboardLoaded || _isUserSearchAllowed();
  }

  @computed
  bool get isLocationNotDefined {
    // make sure we don't have neither the filter nor user's location
    return isDashboardLoaded &&
        !isFilterSetup &&
        dashboardUserState.userLocation == null;
  }

  @computed
  bool get isSearchNotAllowed {
    return isDashboardLoaded &&
        searchPermission?.isAllowed == false &&
        (dashboardUserState.userLocation != null || isFilterSetup);
  }

  @computed
  bool get isFiltersAllowed {
    if (filtersPermission?.isAllowed == true ||
        filtersPermission?.isPromoted == true) {
      return true;
    }

    return false;
  }

  /// watch user loaded updates
  @action
  void _initUserLoadedUpdatesWatcher() {
    _userLoadedUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.isUserLoaded, (dynamic _) {
      isDashboardLoaded = true;
    });
  }

  /// watch user updates
  @action
  void _initUserUpdatesWatcher() {
    _userUpdatesWatcherCancellation = reaction(
      (_) => dashboardUserState.user,
      (dynamic _) {
        // update the current list of permissions
        searchPermission =
            dashboardUserState.getUserPermission(_makeSearchPermissionName);

        filtersPermission =
            dashboardUserState.getUserPermission(_useFiltersPermissionName);

        if (_isUserSearchAllowed()) {
          _searchUsers();
        }
      },
    );
  }

  /// watch user location updates
  @action
  void _initUserLocationUpdatesWatcher() {
    _userLocationUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.userLocation, (dynamic _) {
      if (_isUserSearchAllowed() && !isFilterSetup) {
        // search users using a current user's location
        _searchUsers();
      }
    });
  }

  /// watch last changed profile
  void _initLastChangedProfileWatcher() {
    _lastChangedProfileWatcherCancellation =
        reaction((_) => dashboardUserState.lastChangedProfile, (dynamic _) {
      final changedUserId = dashboardUserState.lastChangedProfile!.id;

      // we need to compare only the top level card
      if (_skipClickedCallback != null &&
          changedUserId == userList[activeUserIndex].id &&
          _lastSkippedProfileId != changedUserId) {
        // make sure we have some difference in the math action property
        if (userList[activeUserIndex].matchAction?.type !=
            dashboardUserState.lastChangedProfile!.matchAction?.type) {
          // synchronize the latest profile's changes
          userList[activeUserIndex] = dashboardUserState
              .mergeLastChangedProfile(userList[activeUserIndex]);

          _lastSkippedProfileId = changedUserId;
          _skipClickedCallback!();
        }
      }
    });
  }

  Future<Position?> checkLocation() async {
    return await dashboardUserState.loadUserLocation();
  }

  @action
  Future<void> _searchUsers() async {
    if (!_isRequestStarted) {
      _isRequestStarted = true;
      isNoUsersDescriptionVisible = false;
      activeUserIndex = 0;

      final filter = filtersPermission?.isAllowed == true
          ? dashboardTinderService.getFilter(
              rootState.getSiteSetting('defaultTinderFilterLocationMin', 0),
              rootState.getSiteSetting('defaultTinderFilterLocationMax', 0),
              rootState.getSiteSetting('defaultTinderFilterDefaultMinAge', 0),
              rootState.getSiteSetting('defaultTinderFilterDefaultMaxAge', 0),
            )
          : null;

      final searchResult = await dashboardTinderService.loadUsers(
        _previousUserIdList,
        filter: filter,
      );

      userList = searchResult != null
          ? searchResult.map((user) => UserModel.fromJson(user)).toList()
          : [];

      if (userList.isEmpty) {
        isNoUsersDescriptionVisible = true;
      }

      // collect user ids to ignore them in the next searching
      _previousUserIdList = userList.map((user) => user.id).toList();
      _isRequestStarted = false;
    }
  }

  void _initAutoSearch() {
    _autoSearchTimer = Timer.periodic(
      Duration(
        milliseconds: rootState.getSiteSetting('tinderSearchTimeout', 0),
      ),
      (_) {
        if (_isUserSearchAllowed()) {
          _searchUsers();
        }
      },
    );
  }

  bool _isUserSearchAllowed({
    bool checkUserList = true,
  }) {
    bool isAllowed = (searchPermission?.isAllowed == true &&
        (dashboardUserState.userLocation != null || isFilterSetup));

    if (checkUserList) {
      return isAllowed && userList.isEmpty;
    }

    return isAllowed;
  }

  UserModel _cloneProfile(UserModel profile) {
    return UserModel.fromJson(profile.toJson());
  }
}
