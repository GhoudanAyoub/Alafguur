import 'package:collection/collection.dart' show IterableExtension;
import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/user_service.dart';
import '../../service/dashboard_conversation_service.dart';
import '../../service/dashboard_matched_user_service.dart';
import '../../service/model/dashboard_conversation_model.dart';
import '../../service/model/dashboard_matched_user_model.dart';
import 'dashboard_user_state.dart';

part 'dashboard_conversation_state.g.dart';

enum ConversationAction { read, unread }

class DashboardConversationState = _DashboardConversationState
    with _$DashboardConversationState;

abstract class _DashboardConversationState with Store {
  final DashboardUserState dashboardUserState;
  final RootState rootState;
  final UserService userService;
  final DashboardConversationService dashboardConversationService;
  final DashboardMatchedUserService dashboardMatchedUserService;

  @observable
  String? userNameFilter;

  @observable
  List<DashboardMatchedUserModel>? matchedUsers;

  @observable
  List<DashboardConversationModel>? conversations;

  @observable
  double matchedUsersScrollOffset = 0;

  @observable
  double conversationsScrollOffset = 0;

  int _userRequestsCount = 0;
  late ReactionDisposer _authWatcherCancellation;
  late ReactionDisposer _lastChangedProfileWatcherCancellation;

  _DashboardConversationState({
    required this.dashboardUserState,
    required this.rootState,
    required this.userService,
    required this.dashboardConversationService,
    required this.dashboardMatchedUserService,
  });

  /// pre initialize (watchers, etc)
  @action
  void init() {
    // init watchers
    _initAuthWatcher();
    _initLastChangedProfileWatcher();

    _userRequestsCount = 0;
  }

  /// unsubscribe watchers and clean resources
  void dispose() {
    _authWatcherCancellation();
    _lastChangedProfileWatcherCancellation();
  }

  /// mark a matched user as viewed
  @action
  Future<void> markMatchedUserAsViewed(int? userId) async {
    if (matchedUsers!.isNotEmpty) {
      final updatableMatchedUser = matchedUsers!.firstWhereOrNull(
        (matchedUser) => matchedUser.user.id == userId,
      );

      if (updatableMatchedUser != null && updatableMatchedUser.isNew) {
        final clonedMatchedUser = _cloneMatchedUser(updatableMatchedUser);
        clonedMatchedUser.isNew = false;

        // refresh the matched user list
        matchedUsers = matchedUsers!
            .map((matchedUser) => matchedUser.id != clonedMatchedUser.id
                ? matchedUser
                : clonedMatchedUser)
            .toList();

        await dashboardMatchedUserService
            .markMatchedUserAsViewed(clonedMatchedUser.id);

        rootState.log(
            '[dashboard_conversation_state+mark_matched_users_as_viewed] restart server updates');
        rootState.restartServerUpdates();
      }
    }
  }

  /// mark a user as read
  @action
  Future<void> markMatchedUserAsRead(
      DashboardMatchedUserModel matchedUser) async {
    final clonedMatchedUser = _cloneMatchedUser(matchedUser);
    clonedMatchedUser.isViewed = true;

    // refresh the matched user list
    matchedUsers = matchedUsers!
        .map((matchedUser) => matchedUser.id != clonedMatchedUser.id
            ? matchedUser
            : clonedMatchedUser)
        .toList();

    await dashboardMatchedUserService
        .markMatchedUserAsRead(clonedMatchedUser.id);

    rootState.log(
        '[dashboard_conversation_state+mark_matched_users_as_read] restart server updates');
    rootState.restartServerUpdates();
  }

  @action
  blockProfile(DashboardConversationModel conversation) {
    final clonedConversation = _cloneConversation(conversation);
    clonedConversation.user.isBlocked = true;
    userService.blockUser(clonedConversation.user.id);
    dashboardUserState.lastChangedProfile = clonedConversation.user;
  }

  @action
  unblockProfile(DashboardConversationModel conversation) {
    final clonedConversation = _cloneConversation(conversation);
    clonedConversation.user.isBlocked = false;
    userService.unblockUser(clonedConversation.user.id);
    dashboardUserState.lastChangedProfile = clonedConversation.user;
  }

  @action
  Future<void> deleteConversation(
    DashboardConversationModel deletableConversation,
  ) async {
    _userRequestsCount++;

    // refresh the conversation list
    conversations = conversations!
        .where((conversation) => conversation.id != deletableConversation.id)
        .toList();

    rootState.log(
        '[dashboard_conversation_state+delete_conversation] restart server updates');
    await dashboardConversationService
        .deleteConversation(deletableConversation.id);
    rootState.restartServerUpdates();

    _userRequestsCount--;
  }

  @action
  Future<void> markConversationAsNew(
    DashboardConversationModel conversation,
  ) {
    return _conversationAction(ConversationAction.unread, conversation);
  }

  @action
  Future<void> markConversationAsRead(
    DashboardConversationModel conversation,
  ) {
    return _conversationAction(ConversationAction.read, conversation);
  }

  @action
  void updateConversations(List? newConversations) {
    // we skip all server updates until the user finishes its changes
    if (_userRequestsCount == 0) {
      if (newConversations != null) {
        conversations = newConversations
            .map((user) => DashboardConversationModel.fromJson(user))
            .toList();

        return;
      }

      conversations = [];
    }
  }

  @action
  void updateMatchedUsers(List? newUsers) {
    if (newUsers != null) {
      matchedUsers = newUsers
          .map((user) => DashboardMatchedUserModel.fromJson(user))
          .toList();

      return;
    }

    matchedUsers = [];
  }

  /// return filtered matched user list
  List<DashboardMatchedUserModel>? getMatchedUsers() {
    matchedUsers!.sort((a, b) {
      if (a.isNew == b.isNew) {
        return -a.createStamp.compareTo(b.createStamp);
      }

      return (a.isNew ? 0 : 1) - (b.isNew ? 0 : 1);
    });

    if (userNameFilter == null) {
      return matchedUsers;
    }

    // filter by a user name
    return matchedUsers!
        .where(
          (matchedUser) => matchedUser.user.userName!.toLowerCase().startsWith(
                userNameFilter!.toLowerCase(),
              ),
        )
        .toList();
  }

  DashboardConversationModel? getUserConversation(int? userId) {
    if (conversations != null) {
      return conversations!.firstWhereOrNull(
        (conversation) => conversation.user.id == userId,
      );
    }

    return null;
  }

  /// return filtered conversation list
  List<DashboardConversationModel>? getConversations() {
    if (userNameFilter == null) {
      return conversations;
    }

    // filter by a user name
    return conversations!
        .where(
          (conversation) => conversation.user.userName!.toLowerCase().startsWith(
                userNameFilter!.toLowerCase(),
              ),
        )
        .toList();
  }

  DashboardMatchedUserModel? getFirstNewMatchedUser() {
    if (matchedUsers != null) {
      return matchedUsers!.firstWhereOrNull(
        (matchedUser) => !matchedUser.isViewed,
      );
    }

    return null;
  }

  int getUnreadConversationsCount() {
    return conversations != null
        ? conversations!
            .where((conversation) => conversation.isNew)
            .toList()
            .length
        : 0;
  }

  int getNewMatchedUsersCount() {
    return matchedUsers != null
        ? matchedUsers!.where((matchedUser) => matchedUser.isNew).toList().length
        : 0;
  }

  bool isConversationExist(int? userId) {
    return conversations!
            .where((conversation) => conversation.user.id == userId)
            .toList()
            .length >
        0;
  }

  bool isChatAllowed(UserModel? profile) {
    if (rootState.isAppTinderMode) {
      // do we have a mutual connection?
      if (profile!.matchAction != null && profile.matchAction!.isMutual!) {
        return true;
      }

      return isConversationExist(profile.id);
    }

    return true;
  }

  bool get isPageLoaded => dashboardUserState.isUserLoaded;

  bool get isAllEmpty =>
      matchedUsers!.isEmpty && conversations!.isEmpty && userNameFilter == null;

  /// watch the auth state
  void _initAuthWatcher() {
    _authWatcherCancellation =
        reaction((_) => rootState.isAuthenticated, (dynamic isAuthenticated) {
      if (!isAuthenticated) {
        userNameFilter = null;
        matchedUsers = [];
        conversations = [];
        matchedUsersScrollOffset = 0;
        conversationsScrollOffset = 0;
      }
    });
  }

  /// watch last changed profile
  void _initLastChangedProfileWatcher() {
    _lastChangedProfileWatcherCancellation =
        reaction((_) => dashboardUserState.lastChangedProfile, (dynamic _) {
      _userRequestsCount++;
      bool restartServerUpdates = false;

      // synchronize the latest profile's changes in the conversation list
      conversations = conversations!.map((conversation) {
        if (conversation.user.id != dashboardUserState.lastChangedProfile!.id) {
          return conversation;
        }

        restartServerUpdates = true;
        final clonedConversation = _cloneConversation(conversation);
        clonedConversation.user =
            dashboardUserState.mergeLastChangedProfile(clonedConversation.user);

        return clonedConversation;
      }).toList();

      if (restartServerUpdates) {
        rootState.log(
            '[dashboard_conversation_state+last_changed_profile] restart server updates');
        rootState.restartServerUpdates();
      }

      _userRequestsCount--;
    });
  }

  DashboardMatchedUserModel _cloneMatchedUser(
    DashboardMatchedUserModel matchedUser,
  ) {
    return DashboardMatchedUserModel.fromJson(matchedUser.toJson());
  }

  DashboardConversationModel _cloneConversation(
    DashboardConversationModel conversation,
  ) {
    return DashboardConversationModel.fromJson(conversation.toJson());
  }

  /// process a conversation action
  Future<void> _conversationAction(
    ConversationAction action,
    DashboardConversationModel conversation,
  ) async {
    _userRequestsCount++;
    final clonedConversation = _cloneConversation(conversation);

    switch (action) {
      case ConversationAction.read:
        clonedConversation.isNew = false;
        _refreshConversationList(clonedConversation);
        await dashboardConversationService
            .markConversationAsRead(conversation.id);
        break;

      case ConversationAction.unread:
        clonedConversation.isNew = true;
        _refreshConversationList(clonedConversation);
        await dashboardConversationService
            .markConversationAsNew(conversation.id);
        break;
    }

    rootState
        .log('[dashboard_conversation_state+action] restart server updates');
    rootState.restartServerUpdates();
    _userRequestsCount--;
  }

  void _refreshConversationList(DashboardConversationModel clonedConversation) {
    // refresh the conversation list
    conversations = conversations!
        .map((conversation) => conversation.id != clonedConversation.id
            ? conversation
            : clonedConversation)
        .toList();
  }
}
