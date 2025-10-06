import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';
import 'model/form/form_element_model.dart';
import 'model/validator_response.dart';

/// Available synchronous validators.
///
/// Synchronous validators shouldn't perform any asynchronous operations, e.g.
/// sending HTTP requests.
///
/// Use the [FormSyncValidators.custom] type to define custom validators.
class FormSyncValidators {
  static const require = 'require';
  static const email = 'email';
  static const number = 'number';
  static const minLength = 'minLength';
  static const maxLength = 'maxLength';
  static const custom = 'custom';
}

/// Available asynchronous validators.
///
/// Asynchronous validators can perform asynchronous operations, e.g. sending
/// HTTP requests.
///
/// Use the [FormAsyncValidators.asyncCustom] type to define custom validators.
class FormAsyncValidators {
  static const userName = 'userName';
  static const userEmail = 'userEmail';
  static const userPassword = 'userPassword';
  static const asyncCustom = 'asyncCustom';
}

/// Form validator parameters. Used to configure the validators.
///
/// The [FormValidatorParams.length] parameter is used for both
/// [FormSyncValidators.minLength] and [FormSyncValidators.maxLength]
/// validators.
///
/// The [FormValidatorParams.callback] parameter is used for both
/// [FormSyncValidators.custom] and [FormAsyncValidators.asyncCustom]
/// validators.
class FormValidatorParams {
  static const id = 'id';
  static const email = 'email';
  static const user = 'user';
  static const userName = 'userName';
  static const oldUserName = 'oldUserName';
  static const length = 'length';
  static const callback = 'callback';
  static const min = 'min';
  static const max = 'max';
}

/// a callback definition for sync custom validators
///
/// example of a model:
///
/// ...
/// validators: [
///   FormValidatorModel(
///     name: FormSyncValidators.custom,
///     params: {
///       FormValidatorParams.callback: customSyncValidator,
///     },
///     message: 'my_custom_lang_key',
///   )
/// ]
/// ...
///
/// example of a callback (place this function somewhere in you class)
///
/// SyncCustomValidatorCallback customSyncValidator() {
///   return (dynamic value, Map<String, FormElementModel> elements) {
///       return value != null ? null : 'error_string';
///   };
/// }
///
typedef SyncCustomValidatorCallback = String? Function(dynamic value, Map<String, FormElementModel> elements);

/// a callback definition for async custom validators
///
/// example of a model:
///
/// ...
/// asyncValidators: [
///   FormAsyncValidatorModel(
///     name: FormAsyncValidators.asyncCustom,
///     params: {
///       FormValidatorParams.callback: customAsyncValidator,
///     },
///     message: 'my_custom_async_lang_key',
///   )
/// ]
/// ...
///
/// example of a callback (place this function somewhere in you class)
///
/// AsyncCustomValidatorCallback customAsyncValidator() {
///   return (dynamic value, Map<String, FormElementModel> elements) async {
///       // your async action here
///       await Future.delayed(const Duration(milliseconds: 1500));
///
///       return value != null ? null : 'error_string';
///   };
/// }
///
typedef AsyncCustomValidatorCallback = Future<String?> Function(dynamic value, Map<String, FormElementModel> elements);

/// a delay between validations (which is used to avoid flooding)
const VALIDATION_INTERVAL_MILL_SEC = 1000;

const DEFAULT_REQUIRE_ERROR_MESSAGE = 'require_validator_error';
const DEFAULT_EMAIL_ERROR_MESSAGE = 'email_validator_error';
const DEFAULT_NUMBER_ERROR_MESSAGE = 'number_validator_error';
const DEFAULT_MAX_LENGTH_ERROR_MESSAGE = 'max_length_validator_error';
const DEFAULT_MIN_LENGTH_ERROR_MESSAGE = 'min_length_validator_error';
const DEFAULT_USER_EMAIL_ERROR_MESSAGE = 'user_email_validator_error';
const DEFAULT_USER_PASSWORD_ERROR_MESSAGE = 'user_password_validator_error';
const DEFAULT_USER_NAME_ERROR_MESSAGE = 'user_name_validator_error';

const DEFAULT_EMAIL_REGEXP = '^([\w\-\.\+\%]*[\w])@((?:[A-Za-z0-9\-]+\.)+[A-Za-z]{2,})\$';

class FormValidationService {
  final HttpService httpService;
  final AuthService authService;

  String? actualEmailRegexp;

  FormValidationService({required this.httpService, required this.authService});

  FormValidationService setEmailRegexp(String? emailRegexp) {
    actualEmailRegexp = emailRegexp;

    return this;
  }

  /// determine a sync validator and call it
  String? callSyncValidator(
    String validatorName,
    dynamic value,
    Map<String, FormElementModel> elements,
    String? customErrorMessage,
    Map<String, dynamic>? validatorParams,
  ) {
    String? errorMessage;

    switch (validatorName) {
      case FormSyncValidators.require:
        errorMessage = validateRequiredData(value, customErrorMessage ?? DEFAULT_REQUIRE_ERROR_MESSAGE);
        break;

      case FormSyncValidators.email:
        errorMessage = validateEmail(value, customErrorMessage ?? DEFAULT_EMAIL_ERROR_MESSAGE);
        break;

      case FormSyncValidators.number:
        final int? min = validatorParams?[FormValidatorParams.min] as int?;
        final int? max = validatorParams?[FormValidatorParams.max] as int?;

        final String? stringValue = value as String?;
        errorMessage = validateNumber(stringValue, customErrorMessage ?? DEFAULT_NUMBER_ERROR_MESSAGE, min, max);
        break;

      case FormSyncValidators.maxLength:
        final int? maxLength = validatorParams?[FormValidatorParams.length] as int?;

        if (maxLength == null) {
          throw ArgumentError('The validator maxLength is not defined');
        }

        final String? stringValue = value as String?;
        errorMessage = validateMaxLength(
          stringValue,
          maxLength,
          customErrorMessage ?? DEFAULT_MAX_LENGTH_ERROR_MESSAGE,
        );
        break;

      case FormSyncValidators.minLength:
        final int? minLength = validatorParams?[FormValidatorParams.length] as int?;

        if (minLength == null) {
          throw ArgumentError('The validator minLength is not defined');
        }

        final String? stringValue = value as String?;
        errorMessage = validateMinLength(
          stringValue,
          minLength,
          customErrorMessage ?? DEFAULT_MIN_LENGTH_ERROR_MESSAGE,
        );
        break;

      case FormSyncValidators.custom:
        final dynamic callbackFactory = validatorParams?[FormValidatorParams.callback];

        if (callbackFactory == null) {
          throw ArgumentError('The validator callback is not defined');
        }

        if (!(callbackFactory is Function)) {
          throw ArgumentError('Invalid callback factory for sync validator');
        }

        // Use a function that returns the correct type
        SyncCustomValidatorCallback Function() typedFactory = callbackFactory as SyncCustomValidatorCallback Function();
        final SyncCustomValidatorCallback callback = typedFactory();
        errorMessage = callback(value, elements);
        break;
    }

    return errorMessage;
  }

  /// determine an async validator and call it
  Future<String?> callAsyncValidator(
    String validatorName,
    dynamic value,
    Map<String, FormElementModel> elements,
    String? customErrorMessage,
    Map<String, dynamic>? validatorParams,
  ) async {
    String? errorMessage;

    switch (validatorName) {
      case FormAsyncValidators.asyncCustom:
        final dynamic callbackFactory = validatorParams![FormValidatorParams.callback];

        if (callbackFactory == null) {
          throw ArgumentError('The async validator callback is not defined');
        }

        if (!(callbackFactory is Function)) {
          throw ArgumentError('Invalid callback factory for async validator');
        }

        // Use a function that returns the correct type
        AsyncCustomValidatorCallback Function() typedFactory =
            callbackFactory as AsyncCustomValidatorCallback Function();
        final AsyncCustomValidatorCallback callback = typedFactory();
        errorMessage = await callback(value, elements);
        break;

      case FormAsyncValidators.userEmail:
        final String? user = (validatorParams![FormValidatorParams.user] as String?) ?? authService.authUser?.name;

        final String? email = value as String?;
        errorMessage = await validateUserEmail(email, user, customErrorMessage ?? DEFAULT_USER_EMAIL_ERROR_MESSAGE);
        break;

      case FormAsyncValidators.userPassword:
        final String? user = (validatorParams![FormValidatorParams.user] as String?) ?? authService.authUser?.name;

        final String? password = value as String?;
        errorMessage = await validateUserPassword(
          password,
          user,
          customErrorMessage ?? DEFAULT_USER_PASSWORD_ERROR_MESSAGE,
        );
        break;

      case FormAsyncValidators.userName:
        final String? oldUserName =
            (validatorParams![FormValidatorParams.oldUserName] as String?) ?? authService.authUser?.name;

        final String? name = value as String?;
        errorMessage = await validateUserName(name, oldUserName, customErrorMessage ?? DEFAULT_USER_NAME_ERROR_MESSAGE);
        break;
    }

    return errorMessage;
  }

  /// check if a data is not empty
  String? validateRequiredData(dynamic value, String error) {
    // check as a null
    if (value == null) {
      return error;
    }

    // check as a map (all properties should not be empty)
    if (value is Map) {
      bool isMapValid = true;

      value.forEach((key, mapValue) {
        String? errorMessage = validateRequiredData(mapValue, error);
        if (errorMessage != null) {
          isMapValid = false;
        }
      });

      if (isMapValid) {
        return null;
      }

      return error;
    }

    // check as a boolean
    if (value is bool && value == true) {
      return null;
    }

    // check as a list
    if (value is List && value.isNotEmpty) {
      return null;
    }

    // check as a string
    if (value is String && value.toString().trim().isNotEmpty) {
      return null;
    }

    // check as a number
    if (value is num) {
      return null;
    }

    return error;
  }

  /// check if a string is a correct email
  String? validateEmail(dynamic value, String error) {
    final String? emailValue = value as String?;
    if (emailValue == null) {
      return null;
    }

    final regex = RegExp((actualEmailRegexp ?? DEFAULT_EMAIL_REGEXP));

    return emailValue.isNotEmpty && regex.hasMatch(emailValue) ? null : error;
  }

  /// check if a string is a correct number
  String? validateNumber(String? value, String error, int? minValue, int? maxValue) {
    if (value == null) {
      return null;
    }

    final number = num.tryParse(value);

    if (number == null) {
      return error;
    }

    if (minValue != null && number < minValue) {
      return error;
    }

    if (maxValue != null && number > maxValue) {
      return error;
    }

    return null;
  }

  /// check if a string is not too big
  String? validateMaxLength(String? value, int maxLength, String error) {
    if (value == null) {
      return null;
    }

    return value.isNotEmpty && value.trim().length > maxLength ? error : null;
  }

  /// check if a string is not too small
  String? validateMinLength(String? value, int minLength, String error) {
    if (value == null) {
      return null;
    }

    return value.isNotEmpty && value.trim().length < minLength ? error : null;
  }

  /// validate user email
  Future<String?> validateUserEmail(String? email, String? user, String error) async {
    // Create a map with the correct type
    final requestData = <String, dynamic>{};
    requestData['email'] = email;
    if (user != null) {
      requestData['user'] = user;
    }

    final responseData = await httpService.post('validators/user-email', data: requestData) as Map<String, dynamic>;

    final result = ValidatorResponse.fromJson(responseData);
    return result.valid != true ? error : null;
  }

  /// validate user password
  Future<String?> validateUserPassword(String? password, String? user, String error) async {
    // Create a map with the correct type
    final requestData = <String, dynamic>{};
    requestData['password'] = password;
    requestData['user'] = user;

    final responseData = await httpService.post('validators/user-password', data: requestData) as Map<String, dynamic>;

    final result = ValidatorResponse.fromJson(responseData);
    return result.valid != true ? error : null;
  }

  /// validate user name
  Future<String?> validateUserName(String? name, String? oldUserName, String error) async {
    // Create a map with the correct type
    final requestData = <String, dynamic>{};
    requestData['userName'] = name;
    if (oldUserName != null) {
      requestData['oldUserName'] = oldUserName;
    }

    final responseData = await httpService.post('validators/user-name', data: requestData) as Map<String, dynamic>;

    final result = ValidatorResponse.fromJson(responseData);
    return result.valid != true ? error : null;
  }
}
