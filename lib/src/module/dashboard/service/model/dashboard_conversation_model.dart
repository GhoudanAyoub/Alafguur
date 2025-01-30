import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../../base/service/model/user_model.dart';

part 'dashboard_conversation_model.g.dart';

@JsonSerializable()
class DashboardConversationModel {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final bool isOpponentRead;

  @JsonKey(required: true)
  bool isNew;

  @JsonKey(required: true)
  final bool isReply;

  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int lastMessageTimestamp;

  @JsonKey(required: true)
  final String previewText;

  @JsonKey(required: true, toJson: ConverterUtility.modelToJson)
  UserModel user;

  DashboardConversationModel({
    required this.id,
    required this.isOpponentRead,
    required this.isNew,
    required this.isReply,
    required this.lastMessageTimestamp,
    required this.previewText,
    required this.user,
  });

  factory DashboardConversationModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardConversationModelToJson(this);
}
