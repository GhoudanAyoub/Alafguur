import 'package:json_annotation/json_annotation.dart';

part 'payment_stripe_sale_preparation_response_model.g.dart';

@JsonSerializable()
class PaymentStripeSalePreparationResponseModel {
  /// Stripe checkout page URL.
  @JsonKey(required: false)
  final String? redirectUrl;

  const PaymentStripeSalePreparationResponseModel({this.redirectUrl});

  factory PaymentStripeSalePreparationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PaymentStripeSalePreparationResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaymentStripeSalePreparationResponseModelToJson(this);
}
