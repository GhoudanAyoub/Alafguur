import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'payment_credit_pack_model.dart';

part 'payment_credits_model.g.dart';

@JsonSerializable()
class PaymentCreditsModel {
  /// Current credit balance.
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int balance;

  /// Is credit actions info available.
  @JsonKey(required: true)
  final bool isInfoAvailable;

  /// Credit packs available for purchase.
  @JsonKey(required: true, toJson: ConverterUtility.modelListToJsonList)
  final List<PaymentCreditPackModel> packs;

  const PaymentCreditsModel({
    required this.balance,
    required this.isInfoAvailable,
    required this.packs,
  });

  factory PaymentCreditsModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreditsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreditsModelToJson(this);
}
