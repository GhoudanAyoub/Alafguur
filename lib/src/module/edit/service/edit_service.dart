
import '../../../app/service/http_service.dart';
import '../../base/service/model/form/form_element_model.dart';

class EditService {
  final HttpService httpService;

  EditService({
    required this.httpService,
  });

  /// get form elements
  Future<List<FormElementModel>> getFormElements() async {
    final List<FormElementModel> formElementList = [];
    final List response = await this.httpService.get('edit-questions');

    // process questions
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
