import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/service/http_service.dart';
import '../../../../app/utility/fake_dart_html_utility.dart'
    if (dart.library.html) 'dart:html'
    show window, document, FormElement, InputElement;
import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/generic_response_model.dart';
import '../../service/model/payment_billing_gateway_model.dart';
import '../../service/model/payment_credit_pack_model.dart';
import '../../service/model/payment_membership_plan_model.dart';
import '../../service/model/payment_sale_initialization_response_model.dart';
import '../../service/payment_service.dart';
import '../../utility/payment_product_converter_utility.dart';

part 'payment_billing_gateways_state.g.dart';

/// Available billing gateway names.
class PaymentBillingGatewayNames {
  /// PayPal billing gateway name.
  static const paypal = 'billingpaypal';

  /// Stripe billing gateway name.
  static const stripe = 'billingstripe';

  /// Taaj billing gateway name.
  static const taaj = 'billingtaaj';
}

class PaymentBillingGatewaysState = _PaymentBillingGatewaysState
    with _$PaymentBillingGatewaysState;

abstract class _PaymentBillingGatewaysState with Store {
  final RootState rootState;
  final PaymentService paymentService;
  final HttpService httpService;
  final SharedPreferences sharedPreferences;

  /// Product not found callback. Called when the requested product couldn't be
  /// found.
  Function? _onProductNotFoundCallback;

  /// Is available billing gateways list loaded.
  @observable
  bool isBillingGatewaysListLoaded = false;

  /// Is payment currently in progress.
  @observable
  bool isPaymentInProgress = false;

  /// Selected billing gateway name.
  @observable
  String selectedGatewayName = '';

  /// True if the demo mode is currently activated.
  bool get isDemoModeActivated => rootState.isDemoModeActivated;

  /// Available billing gateways.
  late Iterable<PaymentBillingGatewayModel> billingGateways;

  /// Requested product. Can be either [PaymentMembershipPlanModel] or
  /// [PaymentCreditPackModel].
  dynamic product;

  String get paypalOrderFormUrl =>
      rootState.getSiteSetting('paypalOrderFormUrl', '');

  _PaymentBillingGatewaysState({
    required this.rootState,
    required this.paymentService,
    required this.httpService,
    required this.sharedPreferences,
  });

  /// Initialize billing gateways state.
  ///
  /// Loads available billing gateways list from the backend.
  @action
  Future<void> init({String? productId, bool loadProduct = false}) async {
    if (!loadProduct) {
      billingGateways = await paymentService.loadBillingGateways();
    } else {
      final originalProductId =
          PaymentProductConverterUtility.deurlifyProductId(productId!);

      final billingGatewaysAndProduct = await paymentService
          .loadBillingGatewaysWithProductData(originalProductId);

      final receivedProduct = billingGatewaysAndProduct.product;

      if (receivedProduct?.id != originalProductId) {
        _onProductNotFoundCallback?.call();
        return;
      }

      product = billingGatewaysAndProduct.product;
      billingGateways = billingGatewaysAndProduct.billingGateways;
    }

    isBillingGatewaysListLoaded = true;
  }

  /// Initialize sale of the selected product. The sale will be processed by the
  /// given billing [gateway].
  @action
  Future<PaymentSaleInitializationResponseModel?> initializeSale(
    PaymentBillingGatewayModel gateway,
  ) {
    isPaymentInProgress = true;

    // Safely access productId with proper type checking
    String productIdStr = '';
    if (product != null) {
      try {
        // Check if product has a productId property that can be converted to string
        final productId = product['productId'] ?? product.productId;
        if (productId != null) {
          productIdStr = productId.toString();
        } else {
          // If productId is null, try to use id instead
          final id = product['id'] ?? product.id;
          if (id != null) {
            productIdStr = id.toString();
          }
        }
      } catch (e) {
        // Handle case where product doesn't have expected structure
        isPaymentInProgress = false;
        return Future.value(null);
      }
    }

    if (productIdStr.isEmpty) {
      isPaymentInProgress = false;
      return Future.value(null);
    }

    final pluginKey = PaymentProductConverterUtility.pluginKeyFromProductId(productIdStr);

    if (pluginKey == null) {
      isPaymentInProgress = false;
      return Future.value(null);
    }

    return paymentService.initializePurchase(product, gateway.name, pluginKey);
  }

  /// Create and submit PayPal payment form for the given [sale].
  Future<bool> createAndSubmitPaypalForm(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final formElements = await paymentService.preparePaypalSale(sale);

    if (formElements.isEmpty) {
      return false;
    }

    final body = document.querySelector('body')!;
    final form = document.createElement('form') as FormElement;

    form.id = 'app-order-form-${sale.saleId}';
    form.action = formElements['form_action_url'].toString();
    form.method = 'post';

    formElements.forEach(
      (key, value) {
        final input = document.createElement('input') as InputElement;

        input.type = 'hidden';
        input.name = key.toString();
        input.value = value != null ? value.toString() : '';

        form.append(input);
      },
    );

    body.append(form);

    httpService.cancelAllRequests();

    form.submit();

    return true;
  }

  /// Prepare the provided [sale] as Stripe sale and redirect to Stripe
  /// checkout. Returns `false` if the sale preparation has failed.
  Future<bool> handleStripeSale(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final data = await paymentService.prepareStripeSale(sale);

    if (data.redirectUrl == null) {
      return false;
    }

    httpService.cancelAllRequests();

    window.location.href = data.redirectUrl!;

    return true;
  }

  /// Set the given [sale] status to `error`.
  Future<GenericResponseModel> markAsError(
    PaymentSaleInitializationResponseModel sale,
  ) {
    return paymentService.markAsError(sale);
  }

  /// Set [onProductNotFoundCallback]. This callback is triggered when the
  /// requested product could not be found.
  void setOnProductNotFoundCallback(Function onProductNotFoundCallback) {
    _onProductNotFoundCallback = onProductNotFoundCallback;
  }
}
