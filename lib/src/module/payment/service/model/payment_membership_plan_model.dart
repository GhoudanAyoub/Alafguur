import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'payment_membership_plan_model.g.dart';

@JsonSerializable()
class PaymentMembershipPlanModel {
  @JsonKey(required: true)
  final int id;

  /// Membership level plan price.
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToDouble)
  final double price;

  /// Membership level plan activity period.
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int period;

  /// Activity period units (days, months, etc.)
  @JsonKey(required: true)
  final String periodUnits;

  /// In-app product ID, used for product identification and native purchases.
  @JsonKey(required: true)
  final String productId;

  /// Is this plan recurring.
  @JsonKey(required: true)
  final bool isRecurring;

  const PaymentMembershipPlanModel({
    required this.id,
    required this.price,
    required this.period,
    required this.periodUnits,
    required this.productId,
    required this.isRecurring,
  });

  factory PaymentMembershipPlanModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMembershipPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMembershipPlanModelToJson(this);
}
