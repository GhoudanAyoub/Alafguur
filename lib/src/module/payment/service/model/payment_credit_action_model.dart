import 'package:json_annotation/json_annotation.dart';

part 'payment_credit_action_model.g.dart';

@JsonSerializable()
class PaymentCreditActionModel {
  /// Translated action title.
  @JsonKey(required: true)
  final String title;

  /// Action cost in credits.
  @JsonKey(required: true)
  final int amount;

  const PaymentCreditActionModel({
    required this.title,
    required this.amount,
  });

  factory PaymentCreditActionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreditActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreditActionModelToJson(this);
}
