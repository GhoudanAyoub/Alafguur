import '../../../app/service/http_service.dart';
import 'model/video_im_api_response_model.dart';

class VideoImService {
  final HttpService? httpService;

  const VideoImService({
    this.httpService,
  });

  /// Send a [notification] to the user identified by the [interlocutorId] that
  /// is a member of a session identified by the [sessionId].
  ///
  /// A notification is an arbitrary JSON object and may contain any data. The
  /// way the notifications are handled depends on the receiver.
  Future<VideoImApiResponseModel> sendNotification(
    int interlocutorId,
    String sessionId,
    Map? notification,
  ) async {
    final response = await this.httpService!.post(
      'video-im/notifications',
      data: {
        'sessionId': sessionId,
        'interlocutorId': interlocutorId,
        'notification': notification,
      },
    );

    return VideoImApiResponseModel.fromJson(response);
  }

  /// Mark notifications with the provided [notificationIds] within the session
  /// identified by [sessionId] as received.
  Future<dynamic> markNotificationsAsReceived(
    String sessionId,
    List<int> notificationIds,
  ) {
    return this.httpService!.put(
      'video-im/notifications/received',
      data: {
        'sessionId': sessionId,
        'notificationIds': notificationIds,
      },
    );
  }
}
