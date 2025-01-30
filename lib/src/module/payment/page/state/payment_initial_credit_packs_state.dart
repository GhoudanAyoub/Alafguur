import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../service/model/payment_credit_pack_model.dart';
import '../../service/model/payment_credits_model.dart';
import '../../service/payment_service.dart';
import 'payment_state.dart';

part 'payment_initial_credit_packs_state.g.dart';

class PaymentInitialCreditPacksState = _PaymentInitialCreditPacksState
    with _$PaymentInitialCreditPacksState;

abstract class _PaymentInitialCreditPacksState with Store {
  final RootState rootState;
  final PaymentState paymentState;
  final PaymentService paymentService;

  /// Widget update request stream subscription.
  StreamSubscription? _widgetUpdateRequestSubscription;

  @observable
  bool isCreditPacksDataLoaded = false;

  @computed
  bool get isNativePurchasePending => paymentState.isNativePurchasePending;

  /// True if the demo mode is currently activated.
  bool get isDemoModeActivated => rootState.isDemoModeActivated;

  /// Credit packs available for purchase and current credit balance data.
  late PaymentCreditsModel creditPacksData;

  /// Billing currency symbol.
  String get billingCurrency => rootState.getSiteSetting('billingCurrency', '');

  _PaymentInitialCreditPacksState({
    required this.rootState,
    required this.paymentState,
    required this.paymentService,
  });

  /// Initialize credit packs purchase widget state.
  ///
  /// Load current credit balance and credit packs available for purchase.
  Future<void> init() async {
    loadCreditPacks();

    _widgetUpdateRequestSubscription =
        paymentState.widgetUpdateRequestStream.listen(_onWidgetUpdateRequested);
  }

  /// Dispose of the resources allocated to the state.
  void dispose() {
    _widgetUpdateRequestSubscription?.cancel();
  }

  /// Load credit packs data from the backend.
  @action
  Future<void> loadCreditPacks() async {
    isCreditPacksDataLoaded = false;

    creditPacksData = await paymentService.loadCreditPacksData();

    // Filter out unavailable purchases if running in the native mode.
    if (!kIsWeb && !rootState.isDemoModeActivated) {
      final availablePacks = creditPacksData.packs.where(
        (pack) => paymentState.nativeProductAvailable(pack.productId),
      );

      creditPacksData = PaymentCreditsModel(
        balance: creditPacksData.balance,
        isInfoAvailable: creditPacksData.isInfoAvailable,
        packs: availablePacks.toList(),
      );
    }

    isCreditPacksDataLoaded = true;
  }

  /// Purchase [creditPack] in the native store.
  Future<bool> handleNativePurchase(PaymentCreditPackModel creditPack) {
    return paymentState.handleNativePurchase(creditPack.productId, true);
  }

  /// Handle widget update request.
  void _onWidgetUpdateRequested(bool _) {
    loadCreditPacks();
  }
}
