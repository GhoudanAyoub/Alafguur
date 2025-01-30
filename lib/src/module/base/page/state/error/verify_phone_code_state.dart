import 'package:mobx/mobx.dart';

import '../../../service/model/validator_response.dart';
import '../../../service/phone_verification_service.dart';
import '../../widget/form/form_builder_widget.dart';

part 'verify_phone_code_state.g.dart';

class VerifyPhoneCodeState = _VerifyPhoneCodeState with _$VerifyPhoneCodeState;

abstract class _VerifyPhoneCodeState with Store {
  final PhoneVerificationService phoneVerificationService;

  @observable
  bool isRequestPending = false;

  _VerifyPhoneCodeState({
    required this.phoneVerificationService,
  });

  void init(FormBuilderWidget formBuilder) {
    formBuilder.registerFormElements(
      phoneVerificationService.getPhoneCodeVerificationFormElements(),
    );
  }

  @action
  Future<ValidatorResponse> verifyPhoneCode(
    String code,
  ) async {
    isRequestPending = true;

    final result = await phoneVerificationService.verifyPhoneCode(
      code,
    );

    isRequestPending = false;

    return result;
  }
}
