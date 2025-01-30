
import '../../../app/service/http_service.dart';

class DashboardMatchedUserService {
  final HttpService httpService;

  DashboardMatchedUserService({
    required this.httpService,
  });

  Future<void> markMatchedUserAsRead(int id) async {
    return await httpService.put('matched-users/$id', data: {
      'isRead': true,
    });
  }

  Future<void> markMatchedUserAsViewed(int id) async {
    return await httpService.put('matched-users/$id', data: {
      'isNew': false,
    });
  }
}
