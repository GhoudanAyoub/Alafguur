import 'package:mobx/mobx.dart';

import '../../../../app/service/random_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_match_action_model.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../service/guest_service.dart';
import '../../service/model/guest_model.dart';

part 'guest_state.g.dart';

class GuestState = _GuestState with _$GuestState;

abstract class _GuestState with Store {
  final DashboardUserState dashboardUserState;
  final RandomService randomService;
  final GuestService guestService;
  final RootState rootState;

  @observable
  bool isPageLoaded = false;

  @observable
  List<GuestModel> guests = [];

  int _userRequestsCount = 0;
  late ReactionDisposer _userLoadedUpdatesWatcherCancellation;
  late ReactionDisposer _lastChangedProfileWatcherCancellation;

  _GuestState({
    required this.dashboardUserState,
    required this.randomService,
    required this.guestService,
    required this.rootState,
  });

  @action
  Future<void> init() async {
    isPageLoaded = dashboardUserState.isUserLoaded;

    // init watchers
    _initUserLoadedUpdatesWatcher();
    _initLastChangedProfileWatcher();

    _userRequestsCount = 0;
  }

  void dispose() {
    _userLoadedUpdatesWatcherCancellation();
    _lastChangedProfileWatcherCancellation();
  }

  @action
  void updateGuests(List? updatedGuests) {
    // we skip all server updates until the user finishes its changes
    if (_userRequestsCount == 0) {
      if (updatedGuests != null) {
        guests =
            updatedGuests.map((guest) => GuestModel.fromJson(guest)).toList();

        return;
      }

      guests = [];
    }
  }

  @action
  Future<void> markGuestsAsRead({int? id}) async {
    _userRequestsCount++;

    // refresh the guest list
    guests = guests.map((guest) {
      if (id != null && guest.id != id) {
        return guest;
      }

      final clonedGuest = _cloneGuest(guest);
      clonedGuest.viewed = true;

      return clonedGuest;
    }).toList();

    rootState.log('[guest_state+mark_guests_as_read] restart server updates');

    id == null
        ? await guestService.markGuestsAsRead()
        : await guestService.markGuestAsRead(id);

    rootState.restartServerUpdates();

    _userRequestsCount--;
  }

  @action
  Future<void> deleteGuest(GuestModel deletableGuest) async {
    _userRequestsCount++;

    // refresh the guest list
    guests = guests.where((guest) => guest.id != deletableGuest.id).toList();

    rootState.log('[guest_state+delete_guest] restart server updates');
    await guestService.deleteGuest(deletableGuest.id);
    rootState.restartServerUpdates();

    _userRequestsCount--;
  }

  /// return the count of new guests
  int getNewGuestsCount() {
    return guests.where((guest) => !guest.viewed!).toList().length;
  }

  void likeProfile(GuestModel guest) {
    final clonedGuest = _cloneGuest(guest);

    // add a new match
    clonedGuest.user!.matchAction = UserMatchActionModel(
      id: randomService.integer(),
      userId: clonedGuest.user!.id!,
      type: MatchActionTypeEnum.like,
    );

    // notify listeners about changes
    dashboardUserState.lastChangedProfile = clonedGuest.user;
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
      // synchronize the latest profile's changes with the guest list
      guests = guests.map((guest) {
        if (guest.user!.id != dashboardUserState.lastChangedProfile!.id) {
          return guest;
        }

        final clonedGuest = _cloneGuest(guest);
        clonedGuest.user =
            dashboardUserState.mergeLastChangedProfile(clonedGuest.user!);

        return clonedGuest;
      }).toList();
    });
  }

  GuestModel _cloneGuest(
    GuestModel guest,
  ) {
    return GuestModel.fromJson(guest.toJson());
  }
}
