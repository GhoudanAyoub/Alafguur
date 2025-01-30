
import '../../../app/service/http_service.dart';

class GdprSettingsService {
  HttpService httpService;

  GdprSettingsService({
    required this.httpService,
  });

  /// Request user personal data download.
  Future<dynamic> requestUserDataDownload() {
    return httpService.post('gdpr/downloads');
  }

  /// Request user personal data deletion.
  Future<dynamic> requestUserDataDeletion() {
    return httpService.post('gdpr/deletions');
  }

  /// Send manual data deletion [message] to the server admin.
  Future<dynamic> sendManualDataDeletionMessage(String? message) {
    return httpService.post(
      'gdpr/messages',
      data: {
        'message': message,
      },
    );
  }
}
