import 'package:get_it/get_it.dart';

import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../base/page/state/root_state.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import 'page/guest_page.dart';
import 'page/state/guest_state.dart';
import 'service/guest_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const GUESTS_MAIN_URL = '/guests';

List<RouteModel> getGuestsRoutes() {
  return [
    RouteModel(
      path: GUESTS_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (Map<String, dynamic> routeParams, Map<String, dynamic> widgetParams) {
        return GuestPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [],
    )
  ];
}

// list of available services
void initGuestsServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => GuestService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerLazySingleton(
    () => GuestState(
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      randomService: serviceLocator.get<RandomService>(),
      guestService: serviceLocator.get<GuestService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );
}
