
import '../../../app/service/http_service.dart';

class GoogleLocationService {
  final HttpService httpService;

  GoogleLocationService({required this.httpService});

  /// load a list of locations based on a keyword
  Future<List?> loadLocations(String? keyword) async {
    return await this.httpService.get(
      'location-autocomplete',
      queryParameters: {
        'q': keyword,
      },
    );
  }
}
