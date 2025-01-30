
import '../../../app/service/http_service.dart';

class DashboardHotListService {
  final HttpService httpService;

  DashboardHotListService({required this.httpService});

  /// join me to the hot list
  Future<List?> joinMeToHotList() async {
    return await httpService.post('hotlist-users/me');
  }

  /// delete me from the hot list
  Future<List?> deleteMeFromHotList() async {
    return await httpService.delete('hotlist-users/me');
  }
}
