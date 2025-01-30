import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_attachment_model.g.dart';

enum AttachmentTypeEnum {
  image,
  doc,
}

@JsonSerializable()
class MessageAttachmentModel {
  @JsonKey(required: true)
  final String downloadUrl;

  @JsonKey(required: true)
  final String fileName;

  @JsonKey(required: true)
  final AttachmentTypeEnum type;

  @JsonKey(ignore: true)
  final Uint8List? bytes;

  @JsonKey(ignore: true)
  final PickedFile? localFile;

  MessageAttachmentModel({
    required this.downloadUrl,
    required this.fileName,
    required this.type,
    this.bytes,
    this.localFile,
  });

  factory MessageAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageAttachmentModelToJson(this);
}
