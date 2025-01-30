import 'package:geolocator/geolocator.dart';

import '../../../app/service/http_service.dart';

class DashboardUserService {
  final HttpService httpService;

  DashboardUserService({
    required this.httpService,
  });

  Future<void> updateLocation(Position location) async {
    return await httpService.put('user-locations/me', data: {
      'latitude': location.latitude,
      'longitude': location.longitude,
    });
  }
}
