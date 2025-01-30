
import '../../../app/service/http_service.dart';
import 'model/form/form_element_model.dart';

class CompleteProfileService {
  final HttpService httpService;

  CompleteProfileService({
    required this.httpService,
  });

  /// get form elements
  Future<List<FormElementModel>> getFormElements() async {
    final List<FormElementModel> formElementList = [];
    final List response =
        await this.httpService.get('complete-profile-questions');

    // extract questions
    response.forEach((questionData) {
      questionData['items'].forEach((question) {
        final formElementModel = FormElementModel.fromJson(question);
        formElementModel.group = questionData['section'];
        formElementList.add(formElementModel);
      });
    });

    return formElementList;
  }
}
