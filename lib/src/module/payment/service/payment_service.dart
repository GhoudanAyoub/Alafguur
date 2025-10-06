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
    final response = await httpService.get('inapps/products');
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentNativeProductsModel.fromJson(safeResponse);
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

    if (result is! Map) {
      throw FormatException('Expected Map response, got ${result.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResult = {};
    try {
      result.forEach((key, value) {
        safeResult[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentNativePurchaseValidationResultModel.fromJson(safeResult);
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
      throw ArgumentError(
        'Invalid product type, either PaymentMembershipPlanModel or PaymentCreditPackModel expected, ${product.runtimeType} given',
      );
    }

    final response = await httpService.post(
      'mobile-billings/inits',
      data: {
        'product': product.toJson(),
        'gatewayKey': gatewayName,
        'pluginKey': pluginKey,
      },
    );

    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentSaleInitializationResponseModel.fromJson(safeResponse);
  }

  /// Load membership levels available for purchase.
  Future<Iterable<PaymentMembershipModel>> loadMemberships() async {
    final response = await httpService.get('memberships');
    
    if (response is! List) {
      throw FormatException('Expected List response, got ${response.runtimeType}');
    }
    
    return response.map((membershipRaw) {
      if (membershipRaw is! Map) {
        throw FormatException('Expected Map item in list, got ${membershipRaw.runtimeType}');
      }
      
      // Convert to Map<String, dynamic> safely
      Map<String, dynamic> safeMembershipRaw = {};
      try {
        membershipRaw.forEach((key, value) {
          safeMembershipRaw[key.toString()] = value;
        });
      } catch (e) {
        throw FormatException('Failed to convert item to Map<String, dynamic>: ${e.toString()}');
      }
      
      return PaymentMembershipModel.fromJson(safeMembershipRaw);
    });
  }

  /// Load information about a membership level by its [id].
  /// 
  /// Returns detailed information about a specific membership level.
  Future<PaymentMembershipModel> loadMembership(int id) async {
    final response = await httpService.get('memberships/$id');
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentMembershipModel.fromJson(safeResponse);
  }

  /// Load credit packs.
  /// 
  /// Returns information about available credit packs for purchase.
  Future<PaymentCreditsModel> loadCreditPacksData() async {
    final response = await httpService.get('credits');
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentCreditsModel.fromJson(safeResponse);
  }

  /// Load credit actions cost info.
  /// 
  /// Returns information about the cost of various credit actions.
  Future<PaymentCreditActionsInfoModel> loadCreditsInfo() async {
    final response = await httpService.get('credits/info');
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentCreditActionsInfoModel.fromJson(safeResponse);
  }

  /// Load billing gateways list.
  Future<Iterable<PaymentBillingGatewayModel>> loadBillingGateways() async {
    final response = await httpService.get('billing-gateways');
    
    if (response is! List) {
      throw FormatException('Expected List response, got ${response.runtimeType}');
    }
    
    return response.map((billingGatewayRaw) {
      if (billingGatewayRaw is! Map) {
        throw FormatException('Expected Map item in list, got ${billingGatewayRaw.runtimeType}');
      }
      
      // Convert to Map<String, dynamic> safely
      Map<String, dynamic> safeBillingGatewayRaw = {};
      try {
        billingGatewayRaw.forEach((key, value) {
          safeBillingGatewayRaw[key.toString()] = value;
        });
      } catch (e) {
        throw FormatException('Failed to convert item to Map<String, dynamic>: ${e.toString()}');
      }
      
      return PaymentBillingGatewayModel.fromJson(safeBillingGatewayRaw);
    });
  }

  /// Load billing gateways list and product data for the given [productId].
  /// 
  /// Returns billing gateways information along with specific product data.
  Future<PaymentBillingGatewaysProductDataModel>
      loadBillingGatewaysWithProductData(String productId) async {
    final response = await httpService.get(
      'billing-gateways/with-product',
      queryParameters: {
        'id': productId,
      },
    );
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentBillingGatewaysProductDataModel.fromJson(safeResponse);
  }

  /// Prepare the given PayPal [sale] and load its form fields.
  Future<Map<String, dynamic>> preparePaypalSale(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final result = await httpService.post(
      '/mobile-billings/prepare/paypal/${sale.saleId}',
    );

    if (result is! Map) {
      throw FormatException('Expected Map response, got ${result.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResult = {};
    try {
      result.forEach((key, value) {
        safeResult[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return safeResult;
  }

  /// Prepare the given Stripe [sale] and get the related Stripe checkout URL.
  /// 
  /// Returns the Stripe checkout URL and other necessary information.
  Future<PaymentStripeSalePreparationResponseModel> prepareStripeSale(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final result = await httpService.post(
      '/mobile-billings/prepare/stripe/${sale.saleId}',
    );

    if (result is! Map) {
      throw FormatException('Expected Map response, got ${result.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResult = {};
    try {
      result.forEach((key, value) {
        safeResult[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return PaymentStripeSalePreparationResponseModel.fromJson(safeResult);
  }

  /// Set the given [sale] status to `error`.
  /// 
  /// Marks a sale as having an error, preventing further processing.
  Future<GenericResponseModel> markAsError(
    PaymentSaleInitializationResponseModel sale,
  ) async {
    final response = await httpService.post(
      '/mobile-billings/mark-as-error/${sale.saleId}',
    );
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }
    
    return GenericResponseModel.fromJson(safeResponse);
  }

  /// Grant trial membership plan identified by the provided [planId] to the
  /// active user.
  ///
  /// Returns empty response on success, throws [ServerException] on failure.
  /// This method doesn't require type casting as it returns the raw response.
  Future<dynamic> grantTrialMembershipPlan(int planId) {
    return httpService.post('memberships/trial/$planId');
  }
}
