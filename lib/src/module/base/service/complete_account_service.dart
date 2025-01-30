
import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';
import 'form_validation_service.dart';
import 'model/form/form_element_model.dart';
import 'model/form/form_validator_model.dart';
import 'user_service.dart';

class CompleteAccountService {
  final HttpService httpService;
  final UserService userService;
  final AuthService authService;

  CompleteAccountService({
    required this.httpService,
    required this.userService,
    required this.authService,
  });

  /// update user's account type
  Future<void> updateAccountType(
    String? accountType,
  ) async {
    await httpService.put(
      'users/${authService.authUser!.id}',
      data: {
        'accountType': accountType,
      },
      queryParameters: {
        'mode': 'completeAccountType',
      },
    );
  }

  /// return form elements
  Future<List<FormElementModel>> getFormElements() async {
    return [
      FormElementModel(
        key: 'accountType',
        label: 'gender_input',
        type: FormElements.radio,
        placeholder: 'gender_input_placeholder',
        values: await userService.loadGendersAsFormElementsValues(),
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }
}
