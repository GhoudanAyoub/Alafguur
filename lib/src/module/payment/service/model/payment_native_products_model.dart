import 'package:json_annotation/json_annotation.dart';

import 'payment_credit_pack_model.dart';
import 'payment_membership_plan_model.dart';

part 'payment_native_products_model.g.dart';

@JsonSerializable()
class PaymentNativeProductsModel {
  /// Membership plans available for purchase.
  final List<PaymentMembershipPlanModel> membershipPlans;

  /// Credit packs available for purchase.
  final List<PaymentCreditPackModel> creditPacks;

  const PaymentNativeProductsModel({
    required this.membershipPlans,
    required this.creditPacks,
  });

  factory PaymentNativeProductsModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentNativeProductsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentNativeProductsModelToJson(this);
}
