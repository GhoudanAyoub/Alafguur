import 'package:json_annotation/json_annotation.dart';

part 'payment_auth_action_model.g.dart';

@JsonSerializable()
class PaymentAuthActionModel {
  /// Translated action label.
  @JsonKey(required: true)
  final String label;

  /// Translated permission names.
  @JsonKey(required: true)
  final List<String> permissions;

  const PaymentAuthActionModel({
    required this.label,
    required this.permissions,
  });

  factory PaymentAuthActionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentAuthActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAuthActionModelToJson(this);
}
