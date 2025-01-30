import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/localization_service.dart';
import '../../base/service/model/form/form_async_validator_model.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import '../../base/service/user_service.dart';
import 'model/email_valid_response.dart';

class JoinInitialService {
  final HttpService httpService;
  final LocalizationService localizationService;
  final UserService userService;

  JoinInitialService({
    required this.httpService,
    required this.localizationService,
    required this.userService,
  });

  /// Required join initial form keys for the [joinInitialFormValuesGuard] route
  /// guard.
  List<String> get guardFormElementsKeys =>
      ['userName', 'password', 'email', 'sex', 'lookingFor', 'avatarKey'];

  /// return join form elements
  Future<List<FormElementModel>> getFormElements(
    int minPasswordLength,
    int maxPasswordLength,
  ) async {
    final genderValues = await userService.loadGendersAsFormElementsValues();

    return [
      FormElementModel(
        key: 'userName',
        label: 'username_input',
        type: FormElements.text,
        placeholder: 'username_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
        asyncValidators: [
          FormAsyncValidatorModel(
            name: FormAsyncValidators.userName,
          ),
        ],
      ),
      FormElementModel(
        key: 'password',
        label: 'password_input',
        type: FormElements.password,
        placeholder: 'password_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.minLength,
            message: localizationService.t(
              'password_min_length_validator_error',
              searchParams: ['length'],
              replaceParams: [minPasswordLength.toString()],
            ),
            params: {
              FormValidatorParams.length: minPasswordLength,
            },
          ),
          FormValidatorModel(
            name: FormSyncValidators.maxLength,
            message: localizationService.t(
              'password_max_length_validator_error',
              searchParams: ['length'],
              replaceParams: [maxPasswordLength.toString()],
            ),
            params: {
              FormValidatorParams.length: maxPasswordLength,
            },
          ),
        ],
      ),
      FormElementModel(
        key: 'repeatPassword',
        label: 'password_repeat_input',
        type: FormElements.password,
        placeholder: 'password_repeat_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.custom,
            params: {
              FormValidatorParams.callback: _validateRepeatPassword,
            },
          ),
        ],
      ),
      FormElementModel(
        group: 'base_input_section',
        key: 'email',
        label: 'email_input',
        type: FormElements.email,
        placeholder: 'email_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.email,
          ),
        ],
        asyncValidators: [
          FormAsyncValidatorModel(
            name: FormAsyncValidators.userEmail,
          ),
        ],
      ),
      FormElementModel(
        group: 'base_input_section',
        key: 'sex',
        label: 'gender_input',
        type: FormElements.radio,
        placeholder: 'gender_input_placeholder',
        values: genderValues,
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
      FormElementModel(
        group: 'base_input_section',
        key: 'lookingFor',
        label: 'looking_for_input',
        type: FormElements.multiCheckbox,
        placeholder: 'looking_for_input_placeholder',
        values: genderValues,
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }

  SyncCustomValidatorCallback _validateRepeatPassword() {
    return (dynamic value, Map<String, FormElementModel> elements) {
      return value != elements['password']!.value
          ? 'password_repeat_validator_error'
          : null;
    };
  }

  Future<EmailValidResponseResponse> checkIfEmailValid( String email ) async {
    final response = await httpService.get('kickbox/is-email-exists/$email');

    return EmailValidResponseResponse.fromJson(response);
  }
}
