import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/localization_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import '../../base/service/model/generic_response_model.dart';
import '../../base/service/model/validator_response.dart';

class ResetPasswordService {
  final HttpService httpService;
  final LocalizationService localizationService;

  ResetPasswordService({
    required this.httpService,
    required this.localizationService,
  });

  /// Send password reset verification code to the given [email].
  Future<GenericResponseModel> sendVerificationMessage(String? email) async {
    final result = await httpService.post(
      'forgot-password',
      data: {
        'email': email,
      },
    );

    return GenericResponseModel.fromJson(result);
  }

  /// Validate password reset verification [code].
  Future<ValidatorResponse> validateEmailVerificationCode(String? code) async {
    final result = await httpService.post(
      'validators/forgot-password-code',
      data: {
        'code': code,
      },
    );

    return ValidatorResponse.fromJson(result);
  }

  /// Fulfill the password reset request.
  Future<GenericResponseModel> assignNewPassword(
    String? code,
    String? password,
  ) async {
    final result = await httpService.put(
      'forgot-password/$code',
      data: {
        'password': password,
      },
    );

    return GenericResponseModel.fromJson(result);
  }

  /// Get check email form elements.
  List<FormElementModel> getCheckEmailFormElements() {
    return [
      FormElementModel(
        key: 'email',
        type: FormElements.email,
        label: 'verify_email_email_input',
        placeholder: 'verify_email_email_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.email,
          ),
        ],
      ),
    ];
  }

  /// Get email verification code form elements.
  List<FormElementModel> getVerificationCodeFormElements(String? code) {
    return [
      FormElementModel(
        key: 'code',
        type: FormElements.text,
        value: code,
        label: 'forgot_password_code_input',
        placeholder: 'forgot_password_code_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }

  /// Get reset password form elements.
  List<FormElementModel> getResetPasswordFormElements(
    dynamic minPasswordLength,
    dynamic maxPasswordLength,
  ) {
    return [
      FormElementModel(
        key: 'password',
        type: FormElements.password,
        label: 'forgot_password_input',
        placeholder: 'forgot_password_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.minLength,
            message: localizationService.t(
                'password_min_length_validator_error',
                searchParams: ['length'],
                replaceParams: [minPasswordLength.toString()]),
            params: {FormValidatorParams.length: minPasswordLength},
          ),
          FormValidatorModel(
            name: FormSyncValidators.maxLength,
            message: localizationService.t(
                'password_max_length_validator_error',
                searchParams: ['length'],
                replaceParams: [maxPasswordLength.toString()]),
            params: {
              FormValidatorParams.length: maxPasswordLength,
            },
          ),
        ],
      ),
      FormElementModel(
        key: 'repeatPassword',
        label: 'password_repeat_input',
        placeholder: 'password_repeat_input_placeholder',
        type: FormElements.password,
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
    ];
  }

  /// Validate the repeat password form field.
  SyncCustomValidatorCallback _validateRepeatPassword() {
    return (dynamic value, Map<String, FormElementModel> elements) {
      return value != elements['password']!.value
          ? 'password_repeat_validator_error'
          : null;
    };
  }
}
