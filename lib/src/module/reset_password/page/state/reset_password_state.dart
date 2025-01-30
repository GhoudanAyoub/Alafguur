import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/model/generic_response_model.dart';
import '../../../base/service/model/validator_response.dart';
import '../../service/reset_password_service.dart';

part 'reset_password_state.g.dart';

class ResetPasswordState = _ResetPasswordState with _$ResetPasswordState;

abstract class _ResetPasswordState with Store {
  final ResetPasswordService resetPasswordService;
  final RootState rootState;

  OnDeepLinkCallback? _deepLinkCallback;

  late ReactionDisposer _deepLinkWatcherCancellation;

  @observable
  bool isRequestPending = false;

  _ResetPasswordState({
    required this.resetPasswordService,
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

  void setDeeplinkCallback(OnDeepLinkCallback deepLinkCallback) {
    _deepLinkCallback = deepLinkCallback;
  }

  /// Send password reset verification code to the given [email].
  @action
  Future<GenericResponseModel> sendVerificationMessage(String? email) async {
    isRequestPending = true;

    final result = await resetPasswordService.sendVerificationMessage(email);

    isRequestPending = false;

    return result;
  }

  /// Validate password reset verification [code].
  @action
  Future<ValidatorResponse> validateEmailVerificationCode(String? code) async {
    isRequestPending = true;

    final result = await resetPasswordService.validateEmailVerificationCode(
      code,
    );

    isRequestPending = false;

    return result;
  }

  /// Fulfill the password reset request.
  @action
  Future<GenericResponseModel> assignNewPassword(
    String? code,
    String? password,
  ) async {
    isRequestPending = true;

    final result = await resetPasswordService.assignNewPassword(
      code,
      password,
    );

    isRequestPending = false;

    return result;
  }

  /// Get check email form elements.
  List<FormElementModel> getCheckEmailFormElements() =>
      resetPasswordService.getCheckEmailFormElements();

  /// Get email verification code form elements.
  List<FormElementModel> getVerificationCodeFormElements(String? code) =>
      resetPasswordService.getVerificationCodeFormElements(code);

  /// Get reset password form elements.
  List<FormElementModel> getResetPasswordFormElements() =>
      resetPasswordService.getResetPasswordFormElements(
        rootState.getSiteSetting('minPasswordLength', 0),
        rootState.getSiteSetting('maxPasswordLength', 0),
      );

  void _initDeepLinkWatcher() {
    _deepLinkWatcherCancellation =
        reaction((_) => rootState.deepLink, (String? link) {
      _deepLinkCallback?.call(link);
    });
  }
}
