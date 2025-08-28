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
  /// unsuccessful [GenericResponseModel] if the email isn't registered or is
  /// already verified.
  /// 
  /// If [email] is null or empty, returns a failed response.
  Future<GenericResponseModel> verifyEmail(String? email) async {
    if (email == null || email.trim().isEmpty) {
      return GenericResponseModel(
        success: false,
        message: 'Email is required',
      );
    }
    
    final response = await httpService.post(
      'verify-email',
      data: {
        'email': email,
      },
    );
    
    if (response is! Map) {
      return GenericResponseModel(
        success: false,
        message: 'Invalid response format',
      );
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: 'Failed to process response: ${e.toString()}',
      );
    }
    
    return GenericResponseModel.fromJson(safeResponse);
  }

  /// Check the email verification [code] and mark the account as verified if
  /// the code matches.
  /// 
  /// If [code] is null or empty, returns an invalid response.
  Future<ValidatorResponse> verifyCode(String? code) async {
    if (code == null || code.trim().isEmpty) {
      return ValidatorResponse(valid: false);
    }
    
    final response = await httpService.post(
      'validators/verify-email-code',
      data: {
        'code': code,
      },
    );
    
    if (response is! Map) {
      return ValidatorResponse(valid: false);
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      return ValidatorResponse(valid: false);
    }
    
    return ValidatorResponse.fromJson(safeResponse);
  }

  /// Get change email form elements
  /// 
  /// Returns a list of form elements for the change email form
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
  /// 
  /// Returns a list of form elements for the code verification form
  /// [verifyCode] is an optional pre-filled verification code
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
