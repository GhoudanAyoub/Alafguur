import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../utility/payment_product_converter_utility.dart';
import 'payment_billing_gateway_model.dart';

part 'payment_billing_gateways_product_data_model.g.dart';

/// Combines billing gateways and product data into one model. Used to retrieve
/// both in one request to recover from the page update.
@JsonSerializable()
class PaymentBillingGatewaysProductDataModel {
  /// List of available billing gateways.
  @JsonKey(required: true, toJson: ConverterUtility.modelListToJsonList)
  final List<PaymentBillingGatewayModel> billingGateways;

  /// Requested product. Can be either [PaymentMembershipPlanModel] or
  /// [PaymentCreditPackModel].
  @JsonKey(fromJson: PaymentProductConverterUtility.jsonToProduct)
  final dynamic product;

  const PaymentBillingGatewaysProductDataModel({
    required this.billingGateways,
    this.product,
  });

  factory PaymentBillingGatewaysProductDataModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PaymentBillingGatewaysProductDataModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaymentBillingGatewaysProductDataModelToJson(this);
}
