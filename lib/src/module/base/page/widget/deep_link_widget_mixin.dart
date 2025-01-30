import 'package:get_it/get_it.dart';

import '../state/root_state.dart';

const DEEP_LINK_RESET_PASSWORD = 'reset-password';
const DEEP_LINK_RESET_PASSWORD_REQUEST = 'reset-password-request';
const DEEP_LINK_EMAIL_VERIFY = 'email-verify-check';

mixin DeepLinkWidgetMixin {
  bool isEmailVerifyLink(String link) {
    final path = Uri.parse(link).pathSegments;

    if (path.first == DEEP_LINK_EMAIL_VERIFY) {
      return true;
    }

    return false;
  }

  String? getEmailVerifyCode(String link) {
    if (isEmailVerifyLink(link)) {
      final path = Uri.parse(link).pathSegments;
      return path.last;
    }
    return null;
  }

  bool isResetPasswordLink(String link) {
    final path = Uri.parse(link).pathSegments;

    if (path.first == DEEP_LINK_RESET_PASSWORD) {
      return true;
    }

    return false;
  }

  bool isResetRequestPasswordLink(String link) {
    final path = Uri.parse(link).pathSegments;

    if (path.first == DEEP_LINK_RESET_PASSWORD_REQUEST) {
      return true;
    }

    return false;
  }

  String? getResetPasswordCode(String link) {
    if (isResetPasswordLink(link)) {
      final path = Uri.parse(link).pathSegments;
      return path.last;
    }
    return null;
  }

  void clearDeepLink() {
    GetIt.instance<RootState>().deepLink = null;
  }
}
