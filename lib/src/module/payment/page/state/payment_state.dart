import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../service/payment_service.dart';
import 'payment_in_app_purchase_state.dart';

part 'payment_state.g.dart';

enum ProductType {
  memberships,
  creditPacks,
}

class PaymentState = _PaymentState with _$PaymentState;

abstract class _PaymentState with Store {
  final RootState rootState;
  final PaymentInAppPurchaseState inAppPurchaseState;
  final PaymentService paymentService;

  /// Stream controller for the payment widget update request stream. Pushing a
  /// value to this stream will cause the listening payment widgets to reload
  /// their data from the backend and update their view.
  late final StreamController<bool> _widgetUpdateRequestController;

  /// Is there a blocking request pending.
  @observable
  bool isRequestPending = false;

  /// Selected product type.
  @observable
  ProductType currentProductType = ProductType.memberships;

  @observable
  bool isNativePurchasePending = false;

  ProductType getActiveCurrentProductType() {
    if (currentProductType == ProductType.memberships &&
        !isMembershipsPluginActive) {
      return ProductType.creditPacks;
    }

    if (currentProductType == ProductType.creditPacks &&
        !isUserCreditsPluginActive) {
      return ProductType.memberships;
    }

    return currentProductType;
  }

  /// Are in-app purchases and payments currently available.
  bool get isPaymentsAvailable =>
      isMembershipsPluginActive || isUserCreditsPluginActive;

  /// Is memberships plugin active.
  bool get isMembershipsPluginActive =>
      rootState.isPluginAvailable('membership');

  /// Is user credits plugin active.
  bool get isUserCreditsPluginActive =>
      rootState.isPluginAvailable('usercredits');

  /// Used to facilitate payment widget updates. When a value is received from
  /// this stream, the listening widget should reload its data from the backend
  /// and update its view using the new data.
  Stream<bool> get widgetUpdateRequestStream =>
      _widgetUpdateRequestController.stream;

  _PaymentState({
    required this.rootState,
    required this.inAppPurchaseState,
    required this.paymentService,
  }) {
    _widgetUpdateRequestController = new StreamController.broadcast();
  }

  /// Handle native purchase identified by the provided [productId], whether the
  /// product is consumable is determined by the [isConsumable] flag.
  ///
  /// Passes the [productId] and [isConsumable] parameters to the
  /// [PaymentInAppPurchaseState.purchase] method.
  @action
  Future<bool> handleNativePurchase(String productId, bool isConsumable) async {
    isNativePurchasePending = true;

    final result = await inAppPurchaseState.purchase(
      productId.toLowerCase(),
      isConsumable,
    );

    return result;
  }

  /// Mark the pending native purchase as completed.
  @action
  void markPendingNativePurchaseAsCompleted() {
    isNativePurchasePending = false;
  }

  /// Return whether the given [productId] is available in the native store.
  bool nativeProductAvailable(String productId) {
    return inAppPurchaseState.products.containsKey(productId);
  }

  /// Update payment-related widgets.
  void updateWidgets() {
    _widgetUpdateRequestController.add(true);
  }
}
