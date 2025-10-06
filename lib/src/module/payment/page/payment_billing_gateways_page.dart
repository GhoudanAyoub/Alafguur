import 'package:application/src/module/payment/payment_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/service/localization_service.dart';
import '../service/model/payment_billing_gateway_model.dart';
import '../service/model/payment_sale_initialization_response_model.dart';
import '../utility/payment_product_validator_utility.dart';
import 'state/payment_billing_gateways_state.dart';
import 'style/payment_billing_gateways_widget_style.dart';
import 'widget/payment_initial_skeleton_widget.dart';

class PaymentBillingGatewaysPage extends AbstractPage {
  const PaymentBillingGatewaysPage(
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
  ) : super(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _PaymentBillingGatewaysPageState createState() =>
      _PaymentBillingGatewaysPageState();
}

class _PaymentBillingGatewaysPageState
    extends State<PaymentBillingGatewaysPage> {
  late final PaymentBillingGatewaysState _state;

  @override
  void initState() {
    super.initState();

    // Determine whether the product should be loaded from the backend by making
    // sure that the widget params object is a map and that it contains a valid
    // product model instance.
    final loadProduct = !(widget.widgetParams is Map &&
        PaymentProductValidatorUtility.validateProductType(
          widget.widgetParams!['product'],
        ));

    _state = GetIt.instance.get<PaymentBillingGatewaysState>();
    _state.product = !loadProduct ? widget.widgetParams!['product'] : null;

    _state.setOnProductNotFoundCallback(_showProductNotFoundAlert);

    _state.init(
      productId: widget.routeParams!['productId'][0].toString(),
      loadProduct: loadProduct,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t('gateway_page_title'),
        body: _state.isBillingGatewaysListLoaded == true
            ? _buildBillingGatewaysList()
            : PaymentInitialSkeletonWidget(),
      ),
    );
  }

  /// Present available billing gateways as a list.
  Widget _buildBillingGatewaysList() {
    return paymentBillingGatewayListContainer(
      _state.billingGateways
          .map(
            (gateway) => paymentBillingGatewayContainer(
              context,
              gateway.name,
              _state.selectedGatewayName == gateway.name,
              _state.isPaymentInProgress,
              onTapCallback: () => _showBillingGatewayPage(gateway),
            ),
          )
          .toList(),
    );
  }

  /// Show product not found alert. The user is returned to the main page after
  /// dismissal.
  void _showProductNotFoundAlert() {
    widget.showAlert(
      context,
      'payments_product_not_found',
      onDismissCallback: () {
        widget.redirectToMainPage(context);
      },
    );
  }

  /// Show payment page for the given [gateway].
  void _showBillingGatewayPage(PaymentBillingGatewayModel gateway) async {
    if (gateway.name == PaymentBillingGatewayNames.taaj) {
      Navigator.pushNamed(context, TAAJ_CUSTOM_URL);
      return;
    }

    if (_state.isDemoModeActivated) {
      widget.showAlert(context, 'payment_disabled_in_demo_mode');

      return;
    }

    if (_state.isPaymentInProgress) {
      return;
    }

    _state.selectedGatewayName = gateway.name;
    final sale = await _state.initializeSale(gateway);

    if (sale == null) {
      widget.showAlert(
        context,
        'payment_sale_initialization_error',
        onDismissCallback: () => widget.redirectToMainPage(context),
      );
    }

    gateway.isRedirectable
        ? _passToRedirectableGateway(gateway, sale!)
        : _passToBasicGateway(gateway, sale!);
  }

  /// Pass [sale] to the redirectable [gateway].
  void _passToRedirectableGateway(
    PaymentBillingGatewayModel gateway,
    PaymentSaleInitializationResponseModel sale,
  ) {
    switch (gateway.name) {
      case PaymentBillingGatewayNames.paypal:
        _launchPaypalBillingGateway(sale);
        break;

      case PaymentBillingGatewayNames.stripe:
        _launchStripeBillingGateway(sale);
        break;

      default:
        widget.showAlert(
          context,
          'payment_unsupported_billing_gateway',
          onDismissCallback: () => widget.redirectToMainPage(context),
        );

        _state.markAsError(sale);
    }
  }

  /// Pass [sale] to the basic [gateway].
  void _passToBasicGateway(
    PaymentBillingGatewayModel gateway,
    PaymentSaleInitializationResponseModel sale,
  ) {
    widget.showAlert(
      context,
      'payment_unsupported_billing_gateway',
      onDismissCallback: () => widget.redirectToMainPage(context),
    );

    _state.markAsError(sale);

    // TODO: implement
  }

  /// Launch PayPal order form to process the given [sale].
  void _launchPaypalBillingGateway(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final result = await _state.createAndSubmitPaypalForm(sale);

    if (!result) {
      widget.showAlert(
        context,
        'payment_cant_open_paypal_order_form',
        onDismissCallback: () => widget.redirectToMainPage(context),
      );

      _state.markAsError(sale);
    }
  }

  /// Prepare Stripe [sale] and redirect to the Stripe checkout page.
  void _launchStripeBillingGateway(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final result = await _state.handleStripeSale(sale);

    if (!result) {
      widget.showAlert(
        context,
        'payment_stripe_sale_preparation_error',
        onDismissCallback: () => widget.redirectToMainPage(context),
      );

      _state.markAsError(sale);
    }
  }
}
