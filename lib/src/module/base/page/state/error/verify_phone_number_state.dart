import 'package:mobx/mobx.dart';

import '../../../service/model/generic_response_model.dart';
import '../../../service/phone_verification_service.dart';
import '../../widget/form/form_builder_widget.dart';
import '../root_state.dart';

part 'verify_phone_number_state.g.dart';

class VerifyPhoneNumberState = _VerifyPhoneNumberState
    with _$VerifyPhoneNumberState;

abstract class _VerifyPhoneNumberState with Store {
  final PhoneVerificationService phoneVerificationService;
  final RootState rootState;

  @observable
  bool isPageLoading = true;

  @observable
  bool isRequestPending = false;

  _VerifyPhoneNumberState({
    required this.phoneVerificationService,
    required this.rootState,
  });

  @action
  Future<void> init(FormBuilderWidget formBuilder) async {
    formBuilder.registerFormElements(
      await phoneVerificationService.getPhoneNumberVerificationFormElements(),
    );

    isPageLoading = false;
  }

  @action
  Future<GenericResponseModel> verifyPhoneNumber(
    String countryCode,
    String phoneNumber,
  ) async {
    isRequestPending = true;

    final result = await phoneVerificationService.verifyPhoneNumber(
      countryCode,
      phoneNumber,
    );

    if (!result.success) {
      rootState.log(
          '[verify_phone_number_state+verify_phone_number] ${result.message}');
    }

    isRequestPending = false;

    return result;
  }
}
