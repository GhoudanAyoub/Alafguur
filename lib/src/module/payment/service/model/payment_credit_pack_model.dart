import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'payment_credit_pack_model.g.dart';

@JsonSerializable()
class PaymentCreditPackModel {
  /// Credit pack ID.
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int id;

  /// Amount of credits in the credit pack.
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int credits;

  /// Credit pack price.
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToDouble)
  final double price;

  /// In-app product ID, used for product identification and native purchases.
  @JsonKey(required: true)
  final String productId;

  /// Contains HTML-formatted product title, legacy parameter, unused.
  @JsonKey(required: false)
  final String? title;

  const PaymentCreditPackModel({
    required this.id,
    required this.credits,
    required this.price,
    required this.productId,
    this.title,
  });

  factory PaymentCreditPackModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreditPackModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreditPackModelToJson(this);
}
