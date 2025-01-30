import 'package:get_it/get_it.dart';

import '../../app/route_guard/required_widget_map_params_guard.dart';
import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../base/page/state/root_state.dart';
import '../base/service/localization_service.dart';
import 'page/email_verification_page.dart';
import 'page/reset_password_page.dart';
import 'page/state/reset_password_state.dart';
import 'page/verification_code_page.dart';
import 'service/reset_password_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const RESET_PASSWORD_MAIN_URL = '/forgot-password';
const RESET_PASSWORD_VERIFY_URL = '/forgot-password/verify-code/:code';
const RESET_PASSWORD_NEW_PASSWORD_URL = '/forgot-password/new-password';

// list of available routes
List<RouteModel> getResetPasswordRoutes() {
  return [
    RouteModel(
      path: RESET_PASSWORD_MAIN_URL,
      visibility: RouteVisibility.guest,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return EmailVerificationPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),
    RouteModel(
      path: RESET_PASSWORD_VERIFY_URL,
      visibility: RouteVisibility.guest,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return VerificationCodePage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),
    RouteModel(
      path: RESET_PASSWORD_NEW_PASSWORD_URL,
      visibility: RouteVisibility.guest,
      guards: [
        requiredWidgetMapParamsGuard([
          'code',
        ]),
      ],
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return ResetPasswordPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),
  ];
}

// list of available services
void initResetPasswordServiceLocator() {
  serviceLocator.registerLazySingleton(
    () => ResetPasswordService(
      httpService: serviceLocator.get<HttpService>(),
      localizationService: serviceLocator.get<LocalizationService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => ResetPasswordState(
      rootState: serviceLocator.get<RootState>(),
      resetPasswordService: serviceLocator.get<ResetPasswordService>(),
    ),
  );
}
