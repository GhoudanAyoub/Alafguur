
import '../../../app/service/http_service.dart';

class GuestService {
  final HttpService httpService;

  GuestService({
    required this.httpService,
  });

  Future<void> deleteGuest(int? id) async {
    return this.httpService.delete('guests/$id');
  }

  Future<void> markGuestAsRead(int id) async {
    return this.httpService.put('guests/$id');
  }

  Future<void> markGuestsAsRead() async {
    return this.httpService.put('guests/me/mark-all-as-read');
  }
}
