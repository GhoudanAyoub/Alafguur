
import '../../../app/service/http_service.dart';
import '../../base/service/model/form/form_element_model.dart';

class EmailNotificationsSettingsService {
  HttpService httpService;

  EmailNotificationsSettingsService({
    required this.httpService,
  });

  /// Save email notifications [settings].
  Future<dynamic> saveSettings(List<Map<String, dynamic>> settings) {
    return httpService.put('email-notifications/me', data: settings);
  }

  /// Load email notifications settings form elements.
  Future<List<FormElementModel>> loadNotificationsSettingsFormElements() async {
    final Iterable<dynamic> questions = await httpService.get(
      'email-notifications/questions',
    );

    return questions
        .map((question) => FormElementModel.fromJson(question))
        .toList();
  }
}
