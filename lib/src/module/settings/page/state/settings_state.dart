import '../../../../app/service/auth_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/user_service.dart';

class SettingsState {
  final AuthService authService;
  final UserService userService;
  final RootState rootState;

  /// Is current user an admin.
  bool get isAdmin => authService.authUser!.isAdmin;

  /// If true, email settings button is shown.
  bool get showEmailSettings => rootState.isPluginAvailable('notifications');

  /// If true, GDPR settings button is shown.
  bool get showGdprSettings => rootState.isPluginAvailable('gdpr');

  /// If true, the Contact us button is shown.
  bool get showContactSettings => rootState.isPluginAvailable('contactus');

  /// If true, GDPR third party settings button is shown.
  bool get showGdprThirdPartySettings =>
      showGdprSettings &&
      rootState.getSiteSetting('gdprThirdPartyServices', 0) == 1;

  SettingsState({
    required this.authService,
    required this.userService,
    required this.rootState,
  });

  /// Delete the current user.
  Future<dynamic> deleteCurrentUser() async {
    return userService.deleteMe();
  }
}
