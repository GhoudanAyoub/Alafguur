import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'message_attachment_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(required: true)
  final dynamic id;

  @JsonKey(required: true)
  final bool isAuthor;

  @JsonKey(required: true)
  final bool isAuthorized;

  @JsonKey(required: true)
  final bool isSystem;

  @JsonKey(required: true, toJson: ConverterUtility.modelListToJsonList)
  List<MessageAttachmentModel> attachments;

  @JsonKey(required: true)
  final String conversation;

  @JsonKey(required: true)
  final int timeStamp;

  @JsonKey(required: true)
  final int updateStamp;

  final String? time;

  final String? tempId;

  String? text;

  final String? date;

  final String? dateLabel;

  @JsonKey(defaultValue: false)
  bool isPending;

  @JsonKey(defaultValue: false)
  bool isLoading;

  @JsonKey(defaultValue: false)
  final bool isRecipientRead;

  String? error;

  MessageModel({
    required this.id,
    required this.isAuthor,
    required this.isAuthorized,
    required this.isSystem,
    required this.attachments,
    required this.conversation,
    required this.timeStamp,
    required this.updateStamp,
    this.time,
    this.tempId,
    this.text,
    this.date,
    this.dateLabel,
    this.isPending = false,
    this.isLoading = false,
    this.isRecipientRead = false,
    this.error,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
