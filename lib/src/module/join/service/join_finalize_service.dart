import '../../../app/service/http_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/user_model.dart';

class JoinFinalizeService {
  final HttpService httpService;

  JoinFinalizeService({
    required this.httpService,
  });

  /// get form elements
  Future<List<FormElementModel>> getFormElements(int? sex) async {
    final List<FormElementModel> formElementList = [];
    final Map response = await this.httpService.get('join-questions/$sex');

    // extract questions
    response['questions'].forEach((questionData) {
      questionData['items'].forEach((question) {
        final formElementModel = FormElementModel.fromJson(question);
        formElementModel.group = questionData['section'];
        formElementList.add(formElementModel);
      });
    });

    return formElementList;
  }

  /// create a user using initial values
  Future<String?> createUser(UserModel initialValues) async {
    final response = await httpService.post(
      'users',
      data: initialValues.toJson(),
    );

    if (response['token'] != null) {
      return response['token'];
    }

    return null;
  }

  /// create user questions
  Future<void> createQuestions(
    UserModel initialValues,
    List<FormElementModel?> finalizeValues,
  ) async {
    // collect the list of questions
    List questions = finalizeValues.map(
      (formElementModel) {
        return {
          'name': formElementModel!.key,
          'value': formElementModel.value,
          'type': formElementModel.type,
        };
      },
    ).toList();

    // add match sex
    questions.add(
      {
        'name': 'match_sex',
        'value': initialValues.lookingFor,
        'type': FormElements.multiCheckbox,
      },
    );

    await httpService.post('questions-data', data: questions);
  }
}
