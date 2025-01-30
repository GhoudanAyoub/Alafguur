import '../../../app/service/http_service.dart';
import 'form_validation_service.dart';
import 'model/form/form_element_model.dart';
import 'model/form/form_validator_model.dart';
import 'model/generic_response_model.dart';
import 'model/validator_response.dart';

class EmailVerificationService {
  final HttpService httpService;

  EmailVerificationService({
    required this.httpService,
  });

  /// Send a verification letter to the provided [email]. Returns an
  /// unsuccessful [GenericApiResponse] if the email isn't registered or is
  /// already verified.
  Future<GenericResponseModel> verifyEmail(String? email) async {
    return GenericResponseModel.fromJson(
      await httpService.post(
        'verify-email',
        data: {
          'email': email,
        },
      ),
    );
  }

  /// Check the email verification [code] and mark the account as verified if
  /// the code matches.
  Future<ValidatorResponse> verifyCode(String? code) async {
    return ValidatorResponse.fromJson(
      await httpService.post(
        'validators/verify-email-code',
        data: {
          'code': code,
        },
      ),
    );
  }

  /// Get change email form elements
  List<FormElementModel> getChangeEmailFormElements() {
    return [
      FormElementModel(
        key: 'email',
        type: FormElements.email,
        placeholder: 'verify_email_email_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.email,
          )
        ],
      ),
    ];
  }

  /// Get code verification form elements
  List<FormElementModel> getCodeVerificationFormElements(
    String? verifyCode,
  ) {
    return [
      FormElementModel(
        key: 'code',
        type: FormElements.text,
        value: verifyCode,
        placeholder: 'verify_email_code_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }
}
