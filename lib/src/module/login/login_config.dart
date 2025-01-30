import 'package:application/src/module/base/service/user_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../base/page/state/root_state.dart';
import '../base/service/firebase_auth_service.dart';
import 'page/login_page.dart';
import 'page/state/login_state.dart';
import 'service/login_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const LOGIN_MAIN_URL = '/login';

// list of available routes
List<RouteModel> getLoginRoutes() {
  return [
    RouteModel(
      path: LOGIN_MAIN_URL,
      visibility: RouteVisibility.guest,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          LoginPage(),
    ),
  ];
}

// list of available services
void initLoginServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => LoginService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerFactory(
    () => LoginState(
      loginService: serviceLocator.get<LoginService>(),
      firebaseAuthService: serviceLocator.get<FirebaseAuthService>(),
      rootState: serviceLocator.get<RootState>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
      userService: serviceLocator.get<UserService>(),
    ),
  );
}
