import 'package:json_annotation/json_annotation.dart';

part 'payment_native_purchase_validation_result_model.g.dart';

@JsonSerializable()
class PaymentNativePurchaseValidationResultModel {
  /// True if the purchase is valid.
  final bool isValid;

  /// True if the purchase represents a subscription renewal.
  final bool isRenewal;

  /// True if the validation result should be ignored.
  final bool ignore;

  const PaymentNativePurchaseValidationResultModel({
    required this.isValid,
    required this.isRenewal,
    required this.ignore,
  });

  factory PaymentNativePurchaseValidationResultModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PaymentNativePurchaseValidationResultModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaymentNativePurchaseValidationResultModelToJson(this);
}
