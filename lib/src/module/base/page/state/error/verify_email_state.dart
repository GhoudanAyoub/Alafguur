import 'package:mobx/mobx.dart';

import '../../../../../app/service/auth_service.dart';
import '../../../service/email_verification_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../../service/model/generic_response_model.dart';
import '../../../service/model/user_model.dart';
import '../../../service/model/validator_response.dart';
import '../../../service/user_service.dart';
import '../root_state.dart';

part 'verify_email_state.g.dart';

class VerifyEmailState = _VerifyEmailState with _$VerifyEmailState;

abstract class _VerifyEmailState with Store {
  final EmailVerificationService emailVerificationService;
  final UserService userService;
  final AuthService authService;
  final RootState rootState;

  OnDeepLinkCallback? _deepLinkCallback;

  late ReactionDisposer _deepLinkWatcherCancellation;

  @observable
  bool isRequestPending = false;

  _VerifyEmailState({
    required this.emailVerificationService,
    required this.userService,
    required this.authService,
    required this.rootState,
  });

  /// pre initialize (watchers, etc)
  void init() {
    _deepLinkCallback?.call(rootState.deepLink);

    _initDeepLinkWatcher();
  }

  void dispose() {
    _deepLinkWatcherCancellation();
  }

  /// Change user email
  @action
  Future<GenericResponseModel> changeEmail(String email) async {
    this.isRequestPending = true;
    final oldEmail = this.authService.authUser!.email;

    if (oldEmail != email) {
      // update user email
      final user = await userService.updateMe(
        UserModel(email: email),
      );

      // authenticate user with new token
      rootState.setAuthenticated(user.token!);
    }

    // send verification code to the new email
    final verificationResult =
        await emailVerificationService.verifyEmail(email);

    this.isRequestPending = false;

    return verificationResult;
  }

  /// Verify the email verification code
  @action
  Future<ValidatorResponse> verifyCode(String code) async {
    this.isRequestPending = true;
    final verificationResult =
        await this.emailVerificationService.verifyCode(code);

    this.isRequestPending = false;

    if (verificationResult.valid) {
      rootState.cleanAppErrors();
    }

    return verificationResult;
  }

  /// Get change email form elements
  List<FormElementModel> getChangeEmailFormElements() =>
      emailVerificationService.getChangeEmailFormElements();

  /// Get code verification form elements
  List<FormElementModel> getCodeVerificationFormElements(String? verifyCode) =>
      emailVerificationService.getCodeVerificationFormElements(verifyCode);

  void setDeeplinkCallback(OnDeepLinkCallback deepLinkCallback) {
    _deepLinkCallback = deepLinkCallback;
  }

  void _initDeepLinkWatcher() {
    _deepLinkWatcherCancellation =
        reaction((_) => rootState.deepLink, (String? link) {
      _deepLinkCallback?.call(link);
    });
  }
}
