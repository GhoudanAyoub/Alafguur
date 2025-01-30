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

  /// login a user
  Future<String?> login(Map credentials) async {
    final response = await httpService.post(
      'login',
      data: credentials,
    );

    if (response['token'] != null) {
      return response['token'];
    }

    return null;
  }

  /// login a user
  Future<String?> firebaseLogin(UserCredential userCredential) async {
    String? userPhoneNumber = userCredential.user!.phoneNumber ??
        userCredential.additionalUserInfo!.profile!['phoneNumber'] ??
        null;

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

    if (response['token'] != null) {
      return response['token'];
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
