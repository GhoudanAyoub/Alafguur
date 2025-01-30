import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../app/service/http_service.dart';
import '../../base/service/model/generic_response_model.dart';
import '../utility/payment_product_validator_utility.dart';
import 'model/payment_billing_gateway_model.dart';
import 'model/payment_billing_gateways_product_data_model.dart';
import 'model/payment_credit_actions_info_model.dart';
import 'model/payment_credits_model.dart';
import 'model/payment_membership_model.dart';
import 'model/payment_native_products_model.dart';
import 'model/payment_native_purchase_validation_result_model.dart';
import 'model/payment_sale_initialization_response_model.dart';
import 'model/payment_stripe_sale_preparation_response_model.dart';

class PaymentService {
  final HttpService httpService;

  const PaymentService({
    required this.httpService,
  });

  /// Load products for native purchases.
  Future<PaymentNativeProductsModel> loadNativeProducts() async {
    return PaymentNativeProductsModel.fromJson(
      await httpService.get('inapps/products'),
    );
  }

  /// Validate the given native [purchase]. If the purchase represents a
  /// subscription, [isSubscription] should be set to `true`.
  Future<PaymentNativePurchaseValidationResultModel> validateNativePurchase(
    PurchaseDetails purchase,
  ) async {
    final validationUri =
        Platform.isAndroid ? 'inapps/validate/android' : 'inapps/validate/ios';

    final result = await httpService.post(
      validationUri,
      data: {
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
      },
    );

    return PaymentNativePurchaseValidationResultModel.fromJson(result);
  }

  /// Initialize purchase of the given [product]. The [product] can be either
  /// [PaymentMembershipPlanModel] or [PaymentCreditPackModel].
  ///
  /// The payment will be processed by the billing gateway identified by the
  /// given [gatewayName]. The [pluginKey] parameter identifies the plugin that
  /// defines the product. This parameter will be used to prepare the sale
  /// accordingly.
  Future<PaymentSaleInitializationResponseModel> initializePurchase(
    dynamic product,
    String gatewayName,
    String pluginKey,
  ) async {
    if (!PaymentProductValidatorUtility.validateProductType(product)) {
      throw new ArgumentError(
        'Invalid product type, either PaymentMembershipPlanModel or PaymentCreditPackModel expected, ${product.runtimeType} given',
      );
    }

    return PaymentSaleInitializationResponseModel.fromJson(
      await httpService.post(
        'mobile-billings/inits',
        data: {
          'product': product.toJson(),
          'gatewayKey': gatewayName,
          'pluginKey': pluginKey,
        },
      ),
    );
  }

  /// Load membership levels available for purchase.
  Future<Iterable<PaymentMembershipModel>> loadMemberships() async {
    return (await httpService.get('memberships') as List).map(
      (membershipRaw) => PaymentMembershipModel.fromJson(membershipRaw),
    );
  }

  /// Load information about a membership level by its [id].
  Future<PaymentMembershipModel> loadMembership(int id) async {
    return PaymentMembershipModel.fromJson(
      await httpService.get('memberships/$id'),
    );
  }

  /// Load credit packs.
  Future<PaymentCreditsModel> loadCreditPacksData() async {
    return PaymentCreditsModel.fromJson(await httpService.get('credits'));
  }

  /// Load credit actions cost info.
  Future<PaymentCreditActionsInfoModel> loadCreditsInfo() async {
    return PaymentCreditActionsInfoModel.fromJson(
      await httpService.get('credits/info'),
    );
  }

  /// Load billing gateways list.
  Future<Iterable<PaymentBillingGatewayModel>> loadBillingGateways() async {
    return (await httpService.get('billing-gateways') as List).map(
      (billingGatewayRaw) => PaymentBillingGatewayModel.fromJson(
        billingGatewayRaw,
      ),
    );
  }

  /// Load billing gateways list and product data for the given [productId].
  Future<PaymentBillingGatewaysProductDataModel>
      loadBillingGatewaysWithProductData(String productId) async {
    return PaymentBillingGatewaysProductDataModel.fromJson(
      await httpService.get(
        'billing-gateways/with-product',
        queryParameters: {
          'id': productId,
        },
      ),
    );
  }

  /// Prepare the given PayPal [sale] and load its form fields.
  Future<Map<String, dynamic>> preparePaypalSale(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final result = await httpService.post(
      '/mobile-billings/prepare/paypal/${sale.saleId}',
    );

    return result as Map<String, dynamic>;
  }

  /// Prepare the given Stripe [sale] and get the related Stripe checkout URL.
  Future<PaymentStripeSalePreparationResponseModel> prepareStripeSale(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final result = await httpService.post(
      '/mobile-billings/prepare/stripe/${sale.saleId}',
    );

    return PaymentStripeSalePreparationResponseModel.fromJson(result);
  }

  /// Set the given [sale] status to `error`.
  Future<GenericResponseModel> markAsError(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    return GenericResponseModel.fromJson(
      await httpService.post('/mobile-billings/mark-as-error/${sale.saleId}'),
    );
  }

  /// Grant trial membership plan identified by the provided [planId] to the
  /// active user.
  ///
  /// Returns empty response on success, throws [ServerException] on failure.
  Future<dynamic> grantTrialMembershipPlan(int planId) {
    return httpService.post('memberships/trial/$planId');
  }
}
