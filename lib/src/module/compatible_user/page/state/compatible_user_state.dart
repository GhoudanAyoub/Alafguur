import 'package:mobx/mobx.dart';

import '../../../../app/service/random_service.dart';
import '../../../base/service/model/user_match_action_model.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../service/compatible_user_service.dart';
import '../../service/model/compatible_user_model.dart';

part 'compatible_user_state.g.dart';

class CompatibleUserState = _CompatibleUserState with _$CompatibleUserState;

abstract class _CompatibleUserState with Store {
  final CompatibleUserService compatibleUserService;
  final DashboardUserState dashboardUserState;
  final RandomService randomService;

  @observable
  bool isPageLoaded = false;

  @observable
  List<CompatibleUserModel> matchedUsers = [];

  late ReactionDisposer _userLoadedUpdatesWatcherCancellation;
  late ReactionDisposer _lastChangedProfileWatcherCancellation;

  _CompatibleUserState({
    required this.compatibleUserService,
    required this.dashboardUserState,
    required this.randomService,
  });

  @action
  Future<void> init() async {
    // load users
    matchedUsers = await compatibleUserService.loadUsers();

    isPageLoaded = dashboardUserState.isUserLoaded;

    // init watchers
    _initUserLoadedUpdatesWatcher();
    _initLastChangedProfileWatcher();
  }

  void dispose() {
    _userLoadedUpdatesWatcherCancellation();
    _lastChangedProfileWatcherCancellation();
  }

  void likeProfile(CompatibleUserModel compatibleUser) {
    final clonedCompatibleUser = _cloneCompatibleUser(compatibleUser);

    // add a new match
    clonedCompatibleUser.user.matchAction = UserMatchActionModel(
      id: randomService.integer(),
      userId: clonedCompatibleUser.user.id!,
      type: MatchActionTypeEnum.like,
    );

    // notify listeners about changes
    dashboardUserState.lastChangedProfile = clonedCompatibleUser.user;
  }

  /// watch user loaded updates
  void _initUserLoadedUpdatesWatcher() {
    _userLoadedUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.isUserLoaded, (dynamic _) {
      isPageLoaded = true;
    });
  }

  /// watch last changed profile
  void _initLastChangedProfileWatcher() {
    _lastChangedProfileWatcherCancellation =
        reaction((_) => dashboardUserState.lastChangedProfile, (dynamic _) {
      // synchronize the latest profile's changes with the compatible user list
      matchedUsers = matchedUsers.map((matchedUser) {
        if (matchedUser.user.id != dashboardUserState.lastChangedProfile!.id) {
          return matchedUser;
        }

        final clonedMatchedUser = _cloneCompatibleUser(matchedUser);
        clonedMatchedUser.user =
            dashboardUserState.mergeLastChangedProfile(clonedMatchedUser.user);

        return clonedMatchedUser;
      }).toList();
    });
  }

  CompatibleUserModel _cloneCompatibleUser(
    CompatibleUserModel compatibleUser,
  ) {
    return CompatibleUserModel.fromJson(compatibleUser.toJson());
  }
}
