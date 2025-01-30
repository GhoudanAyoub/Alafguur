import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:mobx/mobx.dart';

import '../../service/model/payment_membership_model.dart';
import '../../service/model/payment_membership_plan_model.dart';
import '../../service/payment_service.dart';
import 'payment_state.dart';

part 'payment_initial_membership_state.g.dart';

class PaymentInitialMembershipState = _PaymentInitialMembershipState
    with _$PaymentInitialMembershipState;

abstract class _PaymentInitialMembershipState with Store {
  final PaymentState paymentState;
  final PaymentService paymentService;

  /// Widget update request stream subscription.
  StreamSubscription? _widgetUpdateRequestSubscription;

  @observable
  bool membershipsLoaded = false;

  @computed
  bool get isNativePurchasePending => paymentState.isNativePurchasePending;

  /// Membership levels available for purchase.
  late Iterable<PaymentMembershipModel> memberships;

  /// Active membership level.
  PaymentMembershipModel? activeMembership;

  _PaymentInitialMembershipState({
    required this.paymentState,
    required this.paymentService,
  });

  /// Initialize membership widget state.
  ///
  /// Load membership levels available for purchase and get the current active
  /// level.
  void init() {
    loadMemberships();

    _widgetUpdateRequestSubscription =
        paymentState.widgetUpdateRequestStream.listen(_onWidgetUpdateRequested);
  }

  /// Dispose of the resources allocated to the state.
  void dispose() {
    _widgetUpdateRequestSubscription?.cancel();
  }

  /// Load membership levels and plans data from the backend.
  @action
  Future<void> loadMemberships() async {
    membershipsLoaded = false;

    memberships = await paymentService.loadMemberships();

    activeMembership = memberships.firstWhereOrNull(
      (membership) => membership.isActive,
    );

    membershipsLoaded = true;
  }

  /// Grant the given trial membership level [plan] to the active user.
  @action
  Future<void> grantTrialMembershipPlan(PaymentMembershipPlanModel plan) async {
    paymentState.isRequestPending = true;

    try {
      await paymentService.grantTrialMembershipPlan(plan.id);
    } finally {
      paymentState.isRequestPending = false;
    }
  }

  /// Purchase [plan] in the native store.
  Future<bool> handleNativePurchase(PaymentMembershipPlanModel plan) {
    // Non-recurring plans are non-consumable only on iOS, recurring plans are
    // non-consumable on any platform.
    final isConsumable = !Platform.isIOS && !plan.isRecurring;

    return paymentState.handleNativePurchase(plan.productId, isConsumable);
  }

  /// Handle widget update request.
  void _onWidgetUpdateRequested(bool _) {
    loadMemberships();
  }
}
