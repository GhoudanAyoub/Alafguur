import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';
import 'model/form/form_element_model.dart';
import 'model/form/form_element_values_model.dart';
import 'model/user_gender_model.dart';
import 'model/user_model.dart';

const REDIRECT_TO_SUBSCRIBE = 'redirect_to_subscribe';
const SHOWING_POPUP = 'showing_popup';

class UserService {
  final HttpService httpService;
  final AuthService authService;

  UserService({
    required this.httpService,
    required this.authService,
  });

  /// load the logged in user's data
  Future<UserModel> loadMe(bool isPhotoPluginAvaialble) async {
    final List<String> params = ['avatar', 'permissions'];

    if (isPhotoPluginAvaialble) {
      params.add('photos');
    }

    final result = await httpService.get(
      'users/${authService.authUser!.id}',
      queryParameters: {
        'with[]': params,
      },
    );

    return UserModel.fromJson(result as Map<String, dynamic>);
  }

  /// update the logged in user's data
  Future<UserModel> updateMe(UserModel user) async {
    final result = await httpService.put(
      'users/${authService.authUser!.id}',
      data: user.toJson(),
    );

    return UserModel.fromJson(result as Map<String, dynamic>);
  }

  /// update the logged in user's questions
  Future<void> updateMyQuestions(
    List<FormElementModel?> updatedValues, {
    bool isCompleteMode = true,
  }) async {
    List<Map<String, dynamic>> questions = updatedValues.map(
      (formElementModel) {
        return {
          'name': formElementModel!.key,
          'value': formElementModel.value,
          'type': formElementModel.type
        };
      },
    ).toList();

    final Map<String, dynamic> params = isCompleteMode
        ? {
            'mode': 'completeRequiredQuestions',
          }
        : {};

    final dynamic responseData = await httpService.put(
      'questions-data/me',
      data: questions,
      queryParameters: params,
    );
    
    final List<dynamic> result = responseData as List<dynamic>;

    // refresh the auth token if it exists
    result.forEach((dynamic question) {
      final Map<String, dynamic> questionsParams =
          question['params'] != null ? question['params'] as Map<String, dynamic> : <String, dynamic>{};

      if (questionsParams.containsKey('token')) {
        authService.setAuthenticated(questionsParams['token'] as String);
      }
    });
  }

  /// load available genders
  Future<List<UserGenderModel>> loadGenders() async {
    final dynamic response = await httpService.get('user-genders');
    final List<dynamic> genders = response as List<dynamic>;

    return genders
        .map<UserGenderModel>((dynamic gender) => UserGenderModel.fromJson(gender as Map<String, dynamic>))
        .toList();
  }

  /// load available genders as form elements values
  Future<List<FormElementValuesModel>> loadGendersAsFormElementsValues() async {
    final genders = await loadGenders();
    final genderValues = genders
        .map(
          (gender) => FormElementValuesModel(
            value: gender.id,
            title: gender.name,
          ),
        )
        .toList();

    return genderValues;
  }

  /// Delete current user.
  Future<dynamic> deleteMe() {
    return httpService.delete('users/${authService.authUser!.id}');
  }

  /// block a user
  Future<void> blockUser(int? userId) async {
    return httpService.post('users/blocks/$userId');
  }

  /// unblock a user
  Future<void> unblockUser(int? userId) async {
    return httpService.delete('users/blocks/$userId');
  }

  /// redirect to subscribe
  Future<bool> redirectToSubscribe() async {
    final dynamic result = await httpService.get(
      'users/redirect-to-subscribe/${authService.authUser!.id}',
    );

    return result as bool;
  }

  /// showing popup
  Future<bool> showingPopup() async {
    final dynamic result = await httpService.get(
      'users/showing-popup/${authService.authUser!.id}',
    );

    return result as bool;
  }

}
