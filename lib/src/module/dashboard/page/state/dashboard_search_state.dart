import 'package:mobx/mobx.dart';

import '../../../../app/service/auth_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../service/dashboard_search_service.dart';
import 'dashboard_user_state.dart';

part 'dashboard_search_state.g.dart';

class DashboardSearchState = _DashboardSearchState with _$DashboardSearchState;

typedef OnUserNameFilterChangeCallback = Function(String? userName);

abstract class _DashboardSearchState with Store {
  final RootState rootState;
  final DashboardUserState dashboardUserState;
  final AuthService authService;
  final DashboardSearchService dashboardSearchService;

  @observable
  bool isPageLoaded = false;

  @observable
  bool isUserListLoading = false;

  @observable
  bool isFiltersLoading = false;

  @observable
  String? userNameFilter = '';

  @observable
  List<UserModel> userList = [];

  @observable
  UserPermissionModel? permission;

  @observable
  double scrollOffset = 0;

  bool _isPageInitialized = false;
  OnUserNameFilterChangeCallback? _userNameFilterChangeCallback;
  late ReactionDisposer _userLoadedUpdatesWatcherCancellation;
  late ReactionDisposer _userUpdatesWatcherCancellation;
  late ReactionDisposer _userNameFilterWatcherCancellation;
  final String _makeSearchPermissionName = 'base_search_users';

  _DashboardSearchState({
    required this.rootState,
    required this.dashboardUserState,
    required this.authService,
    required this.dashboardSearchService,
  });

  /// pre initialize (watchers, etc)
  @action
  void init() {
    isPageLoaded = dashboardUserState.isUserLoaded;

    if (isPageLoaded) {
      // initial permissions initialization
      permission =
          dashboardUserState.getUserPermission(_makeSearchPermissionName);

      _initialUsersLoading();
    }

    // init watchers
    _initUserLoadedUpdatesWatcher();
    _initUserUpdatesWatcher();
    _initUserNameFilterWatcher();

    Map filter = dashboardSearchService.getFilter()!;

    // init the user name filter
    userNameFilter =
        filter['username'] != null ? filter['username']['value'] : '';
  }

  /// unsubscribe watchers and clean resources
  void dispose() {
    _userLoadedUpdatesWatcherCancellation();
    _userUpdatesWatcherCancellation();
    _userNameFilterWatcherCancellation();
  }

  /// watch user loaded updates
  @action
  void _initUserLoadedUpdatesWatcher() {
    _userLoadedUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.isUserLoaded, (dynamic _) {
      isPageLoaded = true;

      _initialUsersLoading();
    });
  }

  /// watch user updates
  @action
  void _initUserUpdatesWatcher() {
    _userUpdatesWatcherCancellation = reaction(
      (_) => dashboardUserState.user,
      (dynamic _) {
        // update the current list of permissions
        permission =
            dashboardUserState.getUserPermission(_makeSearchPermissionName);
      },
    );
  }

  @action
  _initUserNameFilterWatcher() {
    _userNameFilterWatcherCancellation =
        reaction((_) => userNameFilter, (dynamic _) {
      if (_userNameFilterChangeCallback != null) {
        _userNameFilterChangeCallback!(userNameFilter);
      }
    });
  }

  setUserNameFilterChangeCallback(
      OnUserNameFilterChangeCallback userNameFilterChangeCallback) {
    _userNameFilterChangeCallback = userNameFilterChangeCallback;
  }

  @action
  Future<void> initializeFilters(FormBuilderWidget formBuilder) async {
    isFiltersLoading = true;

    try {
      await dashboardSearchService.loadFormElements();

      formBuilder.registerFormElements(
        dashboardSearchService.getFormElements(
          userGender: null,
          showOnlineFormElement: rootState.getSiteSetting(
            'showOnlineOnlyInSearch',
            false,
          ),
          showPhotoOnlyFormElement: rootState.getSiteSetting(
            'showWithPhotoOnlyInSearch',
            false,
          ),
        ),
      );
    } catch (error) {
      isFiltersLoading = false;

      throw error;
    }

    isFiltersLoading = false;
  }

  @action
  void reloadFilters(FormBuilderWidget formBuilder, String userGender) {
    formBuilder.unregisterAllFormElements();
    formBuilder.registerFormElements(dashboardSearchService.getFormElements(
      userGender: userGender,
      showOnlineFormElement: rootState.getSiteSetting(
        'showOnlineOnlyInSearch',
        false,
      ),
      showPhotoOnlyFormElement: rootState.getSiteSetting(
        'showWithPhotoOnlyInSearch',
        false,
      ),
    ));
  }

  /// search by a user name
  @action
  void searchByUserName(String userName) {
    final Map filterList = {};

    userNameFilter = userName;

    if (userName != '') {
      filterList['username'] = {
        'name': 'username',
        'value': userName,
        'type': 'text',
      };
    }

    _searchUsers(filter: filterList);
  }

  /// search by filters
  @action
  void searchByFilters(List<FormElementModel?> filters) {
    final Map filterList = {};

    // we can only search either by username or by basic filters
    userNameFilter = '';

    filters.forEach(
      (element) => filterList[element!.key] = {
        'name': element.key,
        'value': element.value,
        'type': element.type,
      },
    );

    _searchUsers(filter: filterList);
  }

  @action
  Future<void> _searchUsers({Map? filter}) async {
    isUserListLoading = true;

    try {
      List? searchResult = await dashboardSearchService.searchUsers(filter);
      userList = searchResult != null
          ? searchResult.map((user) => UserModel.fromJson(user)).toList()
          : [];

      _isPageInitialized = true;
    } catch (error) {
      isUserListLoading = false;

      throw error;
    }

    isUserListLoading = false;
  }

  bool get isSearchByUserNameAllowed =>
      rootState.getSiteSetting('isSearchByUserNameActive', false);

  void _initialUsersLoading() {
    if (permission!.isAllowed && !_isPageInitialized) {
      _searchUsers(filter: dashboardSearchService.getFilter());
    }
  }
}
