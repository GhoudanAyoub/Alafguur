import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';

class LoginService {
  final HttpService httpService;

  LoginService({
    required this.httpService,
  });

  /// Login a user with username and password
  /// 
  /// Returns the authentication token if login is successful, null otherwise
  Future<String?> login(Map<String, dynamic> credentials) async {
    final response = await httpService.post(
      'login',
      data: credentials,
    );
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }

    if (safeResponse['token'] != null) {
      final token = safeResponse['token'];
      if (token is String) {
        return token;
      }
    }

    return null;
  }

  /// Login a user with Firebase credentials
  /// 
  /// Returns the authentication token if login is successful, null otherwise
  Future<String?> firebaseLogin(UserCredential userCredential) async {
    // Safely extract phone number with proper type checking
    String? userPhoneNumber = userCredential.user!.phoneNumber;
    
    if (userPhoneNumber == null && 
        userCredential.additionalUserInfo?.profile != null && 
        userCredential.additionalUserInfo!.profile!.containsKey('phoneNumber')) {
      final phoneNumberValue = userCredential.additionalUserInfo!.profile!['phoneNumber'];
      if (phoneNumberValue is String) {
        userPhoneNumber = phoneNumberValue;
      }
    }

    final idToken = await userCredential.user!.getIdToken();

    final data = {
      'displayName': userCredential.user!.displayName,
      'phoneNumber': userPhoneNumber,
      'photoURL': userCredential.user!.photoURL,
      'idToken': idToken,
    };

    final response = await httpService.post(
      'firebase/login',
      data: data,
    );
    
    if (response is! Map) {
      throw FormatException('Expected Map response, got ${response.runtimeType}');
    }
    
    // Convert to Map<String, dynamic> safely
    Map<String, dynamic> safeResponse = {};
    try {
      response.forEach((key, value) {
        safeResponse[key.toString()] = value;
      });
    } catch (e) {
      throw FormatException('Failed to convert response to Map<String, dynamic>: ${e.toString()}');
    }

    if (safeResponse['token'] != null) {
      final token = safeResponse['token'];
      if (token is String) {
        return token;
      }
    }

    return null;
  }

  /// return login form elements
  List<FormElementModel> getFormElements() {
    return [
      FormElementModel(
        key: 'username',
        type: FormElements.text,
        placeholder: 'email_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
      FormElementModel(
        key: 'password',
        type: FormElements.password,
        placeholder: 'password_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }
}
