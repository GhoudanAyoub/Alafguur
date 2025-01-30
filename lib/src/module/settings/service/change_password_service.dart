import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/localization_service.dart';
import '../../base/service/model/form/form_async_validator_model.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';

class ChangePasswordService {
  final HttpService httpService;
  final LocalizationService localizationService;

  ChangePasswordService({
    required this.httpService,
    required this.localizationService,
  });

  List<FormElementModel> getFormElements(
    int minPasswordLength,
    int maxPasswordLength,
  ) {
    final List<FormElementModel> formElementList = [];

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'oldPassword',
        label: 'password_old_input',
        type: FormElements.password,
        placeholder: 'password_old_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
        asyncValidators: [
          FormAsyncValidatorModel(
            name: FormAsyncValidators.userPassword,
          ),
        ],
      ),
    );

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'password',
        label: 'password_new_input',
        type: FormElements.password,
        placeholder: 'password_new_input_placeholder',
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
    );

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'repeatPassword',
        label: 'password_new_repeat_input',
        type: FormElements.password,
        placeholder: 'password_new_repeat_input_placeholder',
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
    );

    return formElementList;
  }

  Future<void> changePassword(
    String oldPassword,
    String password,
    String repeatPassword,
  ) async {
    await httpService.put(
      'users/me/password',
      data: {
        'oldPassword': oldPassword,
        'password': password,
        'repeatPassword': repeatPassword,
      },
    );
  }

  SyncCustomValidatorCallback _validateRepeatPassword() {
    return (dynamic value, Map<String, FormElementModel> elements) {
      return value != elements['password']!.value
          ? 'password_repeat_validator_error'
          : null;
    };
  }
}
