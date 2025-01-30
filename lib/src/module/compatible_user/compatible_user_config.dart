import 'package:get_it/get_it.dart';

import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import 'page/compatible_user_page.dart';
import 'page/state/compatible_user_state.dart';
import 'service/compatible_user_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const COMPATIBLE_USERS_MAIN_URL = '/compatible-users';

List<RouteModel> getCompatibleUsersRoutes() {
  return [
    RouteModel(
      path: COMPATIBLE_USERS_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return CompatibleUserPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [],
    )
  ];
}

// list of available services
void initCompatibleUsersServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => CompatibleUserService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerFactory(
    () => CompatibleUserState(
      compatibleUserService: serviceLocator.get<CompatibleUserService>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      randomService: serviceLocator.get<RandomService>(),
    ),
  );
}
