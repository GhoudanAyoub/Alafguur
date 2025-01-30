
import '../../../app/service/http_service.dart';

/// Provides action tracking and authorization functionality.
class PermissionsService {
  final HttpService httpService;

  const PermissionsService({
    required this.httpService,
  });

  /// Track [action] from the given [group] with optional [extraData].
  Future<dynamic> trackAction({
    required String group,
    required String action,
    Map<String, dynamic>? extraData,
  }) {
    if (extraData == null) {
      extraData = {};
    }

    return this.httpService.post('permissions/track-actions', data: {
      'groupName': group,
      'actionName': action,
      'extra': extraData,
    });
  }
}
