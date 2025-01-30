import 'package:json_annotation/json_annotation.dart';

part 'payment_sale_initialization_response_model.g.dart';

@JsonSerializable()
class PaymentSaleInitializationResponseModel {
  /// Unique ID of this sale.
  @JsonKey(required: true)
  final String saleId;

  const PaymentSaleInitializationResponseModel({
    required this.saleId,
  });

  factory PaymentSaleInitializationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PaymentSaleInitializationResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaymentSaleInitializationResponseModelToJson(this);
}
