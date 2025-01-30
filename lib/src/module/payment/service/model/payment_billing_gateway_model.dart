import 'package:json_annotation/json_annotation.dart';

part 'payment_billing_gateway_model.g.dart';

@JsonSerializable()
class PaymentBillingGatewayModel {
  /// Billing gateway name.
  @JsonKey(required: true)
  final String name;

  /// Does this billing gateway submit payment data via redirect.
  @JsonKey(required: true)
  final bool isRedirectable;

  const PaymentBillingGatewayModel({
    required this.name,
    required this.isRedirectable,
  });

  factory PaymentBillingGatewayModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentBillingGatewayModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentBillingGatewayModelToJson(this);
}
