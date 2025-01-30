
import '../../../app/service/http_service.dart';

class DashboardConversationService {
  final HttpService httpService;

  DashboardConversationService({
    required this.httpService,
  });

  Future<void> markConversationAsRead(String id) async {
    return await httpService.put('mailbox/conversations/$id', data: {
      'isRead': true,
    });
  }

  Future<void> markConversationAsNew(String id) async {
    return await httpService.put('mailbox/conversations/$id', data: {
      'isRead': false,
    });
  }

  Future<void> deleteConversation(String id) async {
    return await httpService.delete('mailbox/conversations/$id');
  }
}
