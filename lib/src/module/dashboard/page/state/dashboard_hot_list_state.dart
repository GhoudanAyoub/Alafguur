import 'package:mobx/mobx.dart';

import '../../../../app/service/auth_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../service/dashboard_hot_list_service.dart';
import '../../service/model/dashboard_hot_list_model.dart';
import 'dashboard_user_state.dart';

part 'dashboard_hot_list_state.g.dart';

class DashboardHotListState = _DashboardHotListState
    with _$DashboardHotListState;

abstract class _DashboardHotListState with Store {
  final RootState rootState;
  final DashboardUserState dashboardUserState;
  final AuthService authService;
  final DashboardHotListService dashboardHotListService;

  @observable
  bool isRequestPending = false;

  @observable
  bool isPageLoaded = false;

  @observable
  List<DashboardHotListModel> hotList = [];

  @observable
  bool isMeInList = false;

  @observable
  UserPermissionModel? permission;

  @observable
  double scrollOffset = 0;

  int _hotListUpdateTime = 0;
  late ReactionDisposer _serverUpdatesWatcherCancellation;
  late ReactionDisposer _userLoggedUpdatesWatcherCancellation;
  late ReactionDisposer _userUpdatesWatcherCancellation;

  final String _serverUpdatesHotListChannel = 'hotList';
  final String _addToHotListPermissionName = 'hotlist_add_to_list';

  _DashboardHotListState({
    required this.rootState,
    required this.dashboardUserState,
    required this.authService,
    required this.dashboardHotListService,
  });

  /// pre initialize (watchers, etc)
  @action
  void init() {
    isPageLoaded = dashboardUserState.isUserLoaded;

    if (isPageLoaded) {
      int? lastChannelUpdateTime = rootState
          .getServerUpdatesLastUpdateTime(_serverUpdatesHotListChannel);

      // initial loading users in the hot list
      if (lastChannelUpdateTime != null &&
          lastChannelUpdateTime > _hotListUpdateTime) {
        _processUsers(
          rootState.getServerUpdates(_serverUpdatesHotListChannel),
          hotListUpdateTime: lastChannelUpdateTime,
        );
      }

      // initial permissions initialization
      permission =
          dashboardUserState.getUserPermission(_addToHotListPermissionName);
    }

    // init watchers
    _initServerUpdatesWatcher();
    _initUserLoadedUpdatesWatcher();
    _initUserUpdatesWatcher();
  }

  @action
  Future<void> joinMeToHotList() async {
    isRequestPending = true;

    try {
      _processUsers(
        await dashboardHotListService.joinMeToHotList(),
      );

      rootState
          .log('[dashboard_hot_list_state+join_me] restart server updates');
      rootState.restartServerUpdates();
    } catch (error) {
      isRequestPending = false;

      throw error;
    }

    isRequestPending = false;
  }

  @action
  Future<void> deleteMeFromHotList() async {
    isRequestPending = true;

    try {
      _processUsers(
        await dashboardHotListService.deleteMeFromHotList(),
      );

      rootState
          .log('[dashboard_hot_list_state+delete_me] restart server updates');
      rootState.restartServerUpdates();
    } catch (error) {
      isRequestPending = false;

      throw error;
    }

    isRequestPending = false;
  }

  /// unsubscribe watchers and clean resources
  void dispose() {
    _serverUpdatesWatcherCancellation();
    _userLoggedUpdatesWatcherCancellation();
    _userUpdatesWatcherCancellation();
  }

  /// check whether is adding to the hot list allowed
  bool isHotListJoinAllowed() {
    if (!isMeInList && (permission!.isAllowed || permission!.isPromoted)) {
      return true;
    }

    return false;
  }

  /// watch server updates
  void _initServerUpdatesWatcher() {
    _serverUpdatesWatcherCancellation =
        reaction((_) => rootState.serverUpdates, (dynamic _) {
      // we should not update the state while there is a user's active request
      if (!isRequestPending) {
        _processUsers(
          rootState.getServerUpdates(_serverUpdatesHotListChannel),
          hotListUpdateTime: rootState
              .getServerUpdatesLastUpdateTime(_serverUpdatesHotListChannel),
        );
      }
    });
  }

  /// watch user updates
  void _initUserLoadedUpdatesWatcher() {
    _userLoggedUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.isUserLoaded, (dynamic _) {
      isPageLoaded = true;
    });
  }

  /// watch user updates
  @action
  void _initUserUpdatesWatcher() {
    _userUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.user, (dynamic _) {
      // update the current list of permissions
      permission =
          dashboardUserState.getUserPermission(_addToHotListPermissionName);
    });
  }

  /// process received users
  void _processUsers(
    List? users, {
    hotListUpdateTime,
  }) {
    isMeInList = false;
    _hotListUpdateTime =
        hotListUpdateTime ?? DateTime.now().millisecondsSinceEpoch;

    // there are no users in the list
    if (users == null) {
      hotList = [];

      return;
    }

    final List<DashboardHotListModel> updatedHotList = [];

    users.forEach((user) {
      final hotListItem = DashboardHotListModel.fromJson(user);
      updatedHotList.add(hotListItem);

      if (hotListItem.user.id == authService.authUser!.id) {
        isMeInList = true;
      }
    });

    hotList = updatedHotList;
  }
}
