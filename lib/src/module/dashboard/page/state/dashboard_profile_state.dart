import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_model.dart';
import '../../../guest/page/state/guest_state.dart';
import '../../../payment/page/state/payment_in_app_purchase_state.dart';
import '../../../payment/page/state/payment_state.dart';
import 'dashboard_user_state.dart';

part 'dashboard_profile_state.g.dart';

class DashboardProfileState = _DashboardProfileState
    with _$DashboardProfileState;

abstract class _DashboardProfileState with Store {
  final DashboardUserState dashboardUserState;
  final RootState rootState;
  final PaymentState paymentState;
  final GuestState guestState;
  final PaymentInAppPurchaseState inAppPurchaseState;

  @observable
  double scrollOffset = 0;

  _DashboardProfileState({
    required this.dashboardUserState,
    required this.rootState,
    required this.paymentState,
    required this.guestState,
    required this.inAppPurchaseState,
  });

  UserModel? get user => dashboardUserState.user;

  int get newGuests => guestState.getNewGuestsCount();

  bool get isInstallationGuideAvailable => kIsWeb && !rootState.isPwaMode;

  bool get isGuestsAvailable => rootState.isPluginAvailable('ocsguests');

  bool get isBookmarksAvailable => rootState.isPluginAvailable('bookmarks');

  bool get isMatchmakingAvailable => rootState.isPluginAvailable('matchmaking');

  bool get isPaymentsAvailable => paymentState.isPaymentsAvailable;

  bool get isPageLoaded => dashboardUserState.isUserLoaded;

  bool get isNativeStoreInitialized => inAppPurchaseState.isStoreInitialized;
}
