import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../base/page/state/root_state.dart';
import '../../service/model/payment_native_products_model.dart';
import '../../service/payment_service.dart';

typedef PaymentNativePurchaseStreamErrorCallback = void Function(dynamic);
typedef PaymentNativePurchaseCallback = void Function(PurchaseDetails);

typedef PaymentNativePurchaseValidationResultCallback = void Function(
  PurchaseDetails,
  bool,
);

typedef PaymentNativePurchaseCompletedCallback = void Function(
  PurchaseDetails,
  bool,
  bool,
);

typedef PaymentNativePurchaseExceptionCallback = void Function(Exception);

/// In-app purchase error codes. Used to determine the error type using the
/// `PurchaseDetails.error.message` field.
class PaymentInAppPurchaseError {
  static const itunesDuplicateProduct = 'storekit_duplicate_product_object';
}

class PaymentInAppPurchaseState {
  final RootState rootState;
  final PaymentService paymentService;
  final InAppPurchase inAppPurchase;

  /// If true, the store has been initialized and the available products have
  /// been registered.
  bool _isStoreInitialized = false;

  /// Purchase stream error callback.
  PaymentNativePurchaseStreamErrorCallback? _onPurchaseStreamErrorCallback;

  /// Purchase status pending callback.
  PaymentNativePurchaseCallback? _onPurchaseStatusPendingCallback;

  /// Purchase status error callback.
  PaymentNativePurchaseCallback? _onPurchaseStatusErrorCallback;

  /// Purchase valid callback.
  PaymentNativePurchaseValidationResultCallback? _onPurchaseValidCallback;

  /// Purchase invalid callback.
  PaymentNativePurchaseValidationResultCallback? _onPurchaseInvalidCallback;

  /// Purchase completed callback.
  PaymentNativePurchaseCompletedCallback? _onPurchaseCompletedCallback;

  /// Native purchase plugin exception callback;
  PaymentNativePurchaseExceptionCallback? _onPurchaseExceptionCallback;

  /// Purchase update subscription handle.
  StreamSubscription? _purchaseUpdateSubscription;

  /// Indicates whether in-app purchases are available.
  Future<bool> get isStoreAvailable => inAppPurchase.isAvailable();

  /// If true, the store has been initialized and the available products have
  /// been registered. Always returns `true` if running in the demo mode.
  bool get isStoreInitialized =>
      rootState.isDemoModeActivated ? true : _isStoreInitialized;

  /// A product ID -> [ProductDetails] mapping containing products available for
  /// purchase in native apps.
  Map<String, ProductDetails> products = {};

  /// Triggered when store encounters an error.
  set onPurchaseStreamErrorCallback(
    PaymentNativePurchaseStreamErrorCallback value,
  ) {
    _onPurchaseStreamErrorCallback = value;
  }

  /// Triggered when a pending purchase was received from the purchase stream.
  /// Accepts [PurchaseDetails] pending purchase as parameter.
  set onPurchaseStatusPendingCallback(PaymentNativePurchaseCallback value) {
    _onPurchaseStatusPendingCallback = value;
  }

  /// Triggered when an erroneous purchase was received from the purchase
  /// stream. Accepts [PurchaseDetails] of the erroneous purchase as parameter.
  set onPurchaseStatusErrorCallback(PaymentNativePurchaseCallback value) {
    _onPurchaseStatusErrorCallback = value;
  }

  /// Triggered when a purchase was successfully validated on the backend.
  /// Accepts [PurchaseDetails] of the validated purchase as parameter.
  set onPurchaseValidCallback(
    PaymentNativePurchaseValidationResultCallback value,
  ) {
    _onPurchaseValidCallback = value;
  }

  /// Triggered when a purchase didn't pass validation on the backend. Accepts
  /// [PurchaseDetails] of the invalid purchase as parameter.
  set onPurchaseInvalidCallback(
    PaymentNativePurchaseValidationResultCallback value,
  ) {
    _onPurchaseInvalidCallback = value;
  }

  /// Triggered when a product has been delivered to the user and the related
  /// purchase has been marked as completed. Accepts [PurchaseDetails] of the
  /// completed purchase as parameter.
  set onPurchaseCompletedCallback(
    PaymentNativePurchaseCompletedCallback value,
  ) {
    _onPurchaseCompletedCallback = value;
  }

  /// Triggered on native purchase plugin exception.
  set onPurchaseExceptionCallback(
    PaymentNativePurchaseExceptionCallback value,
  ) {
    _onPurchaseExceptionCallback = value;
  }

  PaymentInAppPurchaseState({
    required this.rootState,
    required this.paymentService,
    required this.inAppPurchase,
  });

  /// Initialize state.
  void init() async {
    if (isStoreInitialized || !await isStoreAvailable) {
      return;
    }

    PaymentNativeProductsModel inAppProducts;

    try {
      inAppProducts = await paymentService.loadNativeProducts();
    } catch (_) {
      // Do nothing.
      return;
    }

    final productDetailsResponse = await inAppPurchase.queryProductDetails(
      Set.from(
        [
          ...inAppProducts.membershipPlans.map((plan) => plan.productId),
          ...inAppProducts.creditPacks.map((pack) => pack.productId),
        ],
      ),
    );

    products = Map.fromEntries(
      productDetailsResponse.productDetails.map(
        (product) => MapEntry(product.id, product),
      ),
    );

    _purchaseUpdateSubscription = inAppPurchase.purchaseStream.listen(
      _onPurchaseDetailsList,
      onDone: _onPurchaseUpdateStreamDone,
      onError: _onPurchaseUpdateStreamError,
    );

    _isStoreInitialized = true;
  }

  /// Free the allocated resources.
  void dispose() {
    _isStoreInitialized = false;
    products = {};

    _purchaseUpdateSubscription?.cancel();
  }

  /// Purchase the product identified by the provided [productId],
  /// [isConsumable] flag determines whether the product is consumable or not.
  ///
  /// Example consumable products: credit packs, video IM minutes, etc.,
  /// anything that can be spent (i.e. consumed).
  ///
  /// Example non-consumable products: subscriptions, unlimited access to
  /// various resources, etc.
  Future<bool> purchase(String productId, bool isConsumable) async {
    if (!isStoreInitialized ||
        !await isStoreAvailable ||
        !products.containsKey(productId)) {
      return Future.value(false);
    }

    final product = products[productId]!;
    final productDetails = PurchaseParam(productDetails: product);

    try {
      final result = isConsumable
          ? await inAppPurchase.buyConsumable(purchaseParam: productDetails)
          : await inAppPurchase.buyNonConsumable(purchaseParam: productDetails);

      return result;
    } on Exception catch (e) {
      _onPurchaseExceptionCallback?.call(e);

      return false;
    }
  }

  /// Handle purchases received from the purchase stream.
  void _onPurchaseDetailsList(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach(_handlePurchase);
  }

  /// Handle the provided native [purchase].
  void _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _validateCompletedPurchase(purchase);
        return;

      case PurchaseStatus.pending:
        await _validatePendingPurchase(purchase);
        break;

      case PurchaseStatus.error:
        _onPurchaseStatusErrorCallback?.call(purchase);
        break;
    }

    if (purchase.pendingCompletePurchase) {
      await inAppPurchase.completePurchase(purchase);
      _onPurchaseCompletedCallback?.call(purchase, false, false);
    }
  }

  /// Handle purchase stream exhaustion.
  void _onPurchaseUpdateStreamDone() {
    _purchaseUpdateSubscription?.cancel();
  }

  /// Handle purchase stream [error].
  void _onPurchaseUpdateStreamError(dynamic error) {
    _onPurchaseStreamErrorCallback?.call(error);
  }

  /// Validate and formally complete the given [purchase]. Should be used only
  /// if the [purchase]'s `status` value equals to [PurchaseStatus.purchased] or
  /// [PurchaseStatus.restored].
  Future<void> _validateCompletedPurchase(PurchaseDetails purchase) async {
    final validationResult =
        await paymentService.validateNativePurchase(purchase);

    if (validationResult.isValid && !validationResult.ignore) {
      _onPurchaseValidCallback?.call(purchase, validationResult.isRenewal);
    } else {
      _onPurchaseInvalidCallback?.call(purchase, validationResult.isRenewal);
    }

    if (purchase.pendingCompletePurchase) {
      await inAppPurchase.completePurchase(purchase);

      if (!validationResult.ignore) {
        _onPurchaseCompletedCallback?.call(
          purchase,
          validationResult.isValid,
          validationResult.isRenewal,
        );
      }
    }
  }

  /// Validate pending [purchase]. Should be used only if the [purchase]'s
  /// `status` value equals to [PurchaseStatus.pending].
  Future<void> _validatePendingPurchase(PurchaseDetails purchase) async {
    // Pending purchases should be validated only on Android.
    if (!Platform.isAndroid) {
      return;
    }

    final validationResult =
        await paymentService.validateNativePurchase(purchase);

    validationResult.isValid
        ? _onPurchaseValidCallback?.call(
            purchase,
            validationResult.isRenewal,
          )
        : _onPurchaseInvalidCallback?.call(
            purchase,
            validationResult.isRenewal,
          );

    _onPurchaseStatusPendingCallback?.call(purchase);
  }
}
