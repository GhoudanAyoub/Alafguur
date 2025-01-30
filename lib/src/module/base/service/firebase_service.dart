
import '../../../app/service/http_service.dart';

class FirebaseService {
  final HttpService httpService;

  const FirebaseService({
    required this.httpService,
  });

  /// Register device to receive Push notifications.
  ///
  /// The device is identified by its [deviceId]. The provided [fcmToken] will
  /// be used to identify the device within the FCM infrastructure and the
  /// [platform] identifier will determine the appropriate delivery method.
  Future<dynamic> registerDevice({
    required String? deviceId,
    required String? fcmToken,
    required String platform,
    required String? language,
  }) {
    return httpService.post(
      'devices',
      data: {
        'deviceUuid': deviceId,
        'token': fcmToken,
        'platform': platform,
        'language': language,
      },
    );
  }

  /// Unregister device by its [deviceId]. This prevents the device from
  /// receiving Push notifications.
  Future<dynamic> unregisterDevice({
    required String? deviceId,
  }) {
    return httpService.delete(
      'devices',
      data: {
        'deviceId': deviceId,
      },
    );
  }
}
