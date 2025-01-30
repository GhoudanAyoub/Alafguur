import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'payment_auth_action_model.dart';
import 'payment_membership_plan_model.dart';

part 'payment_membership_model.g.dart';

@JsonSerializable()
class PaymentMembershipModel {
  /// Membership ID.
  @JsonKey(required: true)
  final int id;

  /// Membership title.
  @JsonKey(required: true)
  final String title;

  /// Is this membership currently active.
  @JsonKey(required: true)
  final bool isActive;

  /// Is this membership currently active in trial mode.
  @JsonKey(required: true)
  final bool isActiveAndTrial;

  /// Are subscription plans available for this membership.
  @JsonKey(required: true)
  final bool isPlansAvailable;

  /// Relative expiration date.
  @JsonKey(required: true)
  final String? expire;

  /// Is this membership recurring.
  @JsonKey(required: true)
  final bool isRecurring;

  /// Action permissions this membership grants to the user.
  @JsonKey(toJson: ConverterUtility.modelListToJsonList, defaultValue: [])
  final List<PaymentAuthActionModel> actions;

  /// Membership level plans available for purchase.
  @JsonKey(toJson: ConverterUtility.modelListToJsonList, defaultValue: [])
  final List<PaymentMembershipPlanModel> plans;

  PaymentMembershipModel({
    required this.id,
    required this.title,
    required this.isActive,
    required this.isActiveAndTrial,
    required this.isPlansAvailable,
    required this.expire,
    required this.isRecurring,
    required this.actions,
    required this.plans,
  });

  factory PaymentMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMembershipModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMembershipModelToJson(this);
}
