import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'payment_credit_action_model.dart';

part 'payment_credit_actions_info_model.g.dart';

@JsonSerializable()
class PaymentCreditActionsInfoModel {
  /// Actions that increase the user's credit balance.
  @JsonKey(required: true, toJson: ConverterUtility.modelListToJsonList)
  final List<PaymentCreditActionModel> earning;

  /// Actions that decrease the user's credit balance.
  @JsonKey(required: true, toJson: ConverterUtility.modelListToJsonList)
  final List<PaymentCreditActionModel> losing;

  const PaymentCreditActionsInfoModel({
    required this.earning,
    required this.losing,
  });

  factory PaymentCreditActionsInfoModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreditActionsInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreditActionsInfoModelToJson(this);
}
