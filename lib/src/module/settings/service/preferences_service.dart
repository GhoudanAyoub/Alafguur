
import '../../../app/service/http_service.dart';
import '../../base/service/model/form/form_element_model.dart';

class PreferencesService {
  HttpService httpService;

  PreferencesService({
    required this.httpService,
  });

  /// Save [preferences] to the server.
  Future<dynamic> savePreferences(List<Map<String, dynamic>> preferences) {
    return httpService.put('preferences/me', data: preferences);
  }

  /// Load questions from the given preferences [section].
  Future<List<FormElementModel>> loadSectionFormElements(String section) async {
    final Iterable<dynamic> questions = await httpService.get(
      'preferences/questions/$section',
    );

    return questions
        .map((question) => FormElementModel.fromJson(question))
        .toList();
  }
}
