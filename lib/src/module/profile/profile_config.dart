import 'package:get_it/get_it.dart';

import '../../app/route_guard/required_route_params_guard.dart';
import '../../app/service/auth_service.dart';
import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../base/base_config.dart';
import '../base/page/state/root_state.dart';
import '../base/service/bookmark_profile_service.dart';
import '../base/service/permissions_service.dart';
import '../base/service/user_service.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import '../video_im/page/state/video_im_state.dart';
import 'page/profile_page.dart';
import 'page/state/profile_state.dart';
import 'service/profile_service.dart';

final serviceLocator = GetIt.instance;

// list of available routes
List<RouteModel> getProfileRoutes() {
  return [
    RouteModel(
      path: BASE_PROFILE_URL,
      visibility: RouteVisibility.member,
      guards: [
        requiredRouteParamsGuard(['id']),
      ],
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          ProfilePage(routeParams: routeParams, widgetParams: widgetParams),
    ),
  ];
}

// list of available services
void initProfileServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => ProfileService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerFactory(
    () => ProfileState(
      profileService: serviceLocator.get<ProfileService>(),
      authService: serviceLocator.get<AuthService>(),
      videoImState: serviceLocator.get<VideoImState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      userService: serviceLocator.get<UserService>(),
      permissionsService: serviceLocator.get<PermissionsService>(),
      bookmarkProfileService: serviceLocator.get<BookmarkProfileService>(),
      randomService: serviceLocator.get<RandomService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );
}
