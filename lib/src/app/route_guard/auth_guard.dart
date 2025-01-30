import 'package:get_it/get_it.dart';

import '../../module/base/page/access_denied_page.dart';
import '../../module/login/page/login_page.dart';
import '../service/auth_service.dart';
import '../service/model/route_model.dart';

/// Auth guard checks whether the desired page can be rendered in the current
/// auth state.
///
/// It requires [serviceLocator] in order to retrieve the global [AuthService]
/// instance.
RouteGuard authGuard() {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    final authService = serviceLocator.get<AuthService>();
    final currentVisibility = authService.isAuthenticated
        ? RouteVisibility.member
        : RouteVisibility.guest;

    if (model.visibility == currentVisibility ||
        model.visibility == RouteVisibility.all) {
      return null;
    }

    // prevent logged in members from accessing guest-only pages
    if (model.visibility == RouteVisibility.guest &&
        currentVisibility == RouteVisibility.member) {
      return AccessDeniedPage();
    }

    return LoginPage();
  };
}
