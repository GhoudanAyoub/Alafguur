import 'package:json_annotation/json_annotation.dart';

part 'video_im_call_permission_model.g.dart';

@JsonSerializable()
class VideoImCallPermissionModel {
  /// Is video call permitted.
  final bool isPermitted;

  /// Permission error message.
  final String? errorMessage;

  /// Permission error code.
  final int? errorCode;

  const VideoImCallPermissionModel({
    required this.isPermitted,
    this.errorMessage,
    this.errorCode,
  });

  factory VideoImCallPermissionModel.fromJson(Map<String, dynamic> json) =>
      _$VideoImCallPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoImCallPermissionModelToJson(this);
}
