import 'package:json_annotation/json_annotation.dart';

import '../../../base/service/model/user_model.dart';

part 'video_im_notification_model.g.dart';

class VideoImNotificationType {
  static const String notSupported = 'not_supported';
  static const String notPermitted = 'not_permitted';
  static const String creditsOut = 'credits_out';
  static const String blocked = 'blocked';
  static const String candidate = 'candidate';
  static const String answer = 'answer';
  static const String offer = 'offer';
  static const String declined = 'declined';
  static const String bye = 'bye';
}

@JsonSerializable()
class VideoImNotificationModel {
  // Notification ID.
  @JsonKey(includeIfNull: false)
  final int id;

  /// Notification type.
  final String type;

  /// Notification body. Contains arbitrary data.
  @JsonKey(name: 'notification')
  final Map notificationBody;

  /// ID of the session this notification belongs to.
  final String sessionId;

  /// Notification sender user data.
  final UserModel user;

  VideoImNotificationModel({
    required this.id,
    required this.type,
    required this.notificationBody,
    required this.sessionId,
    required this.user,
  });

  factory VideoImNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$VideoImNotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoImNotificationModelToJson(this);
}
