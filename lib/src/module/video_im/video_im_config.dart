import 'package:browser_detector/browser_detector.dart';
import 'package:get_it/get_it.dart';

import '../../app/service/auth_service.dart';
import '../../app/service/http_service.dart';
import '../../app/service/random_service.dart';
import '../base/page/state/root_state.dart';
import '../base/service/permissions_service.dart';
import '../base/service/user_service.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import 'page/state/video_im_accept_call_state.dart';
import 'page/state/video_im_call_state.dart';
import 'page/state/video_im_state.dart';
import 'service/video_im_service.dart';

final serviceLocator = GetIt.instance;

void initVideoImServiceLocator() {
  serviceLocator.registerLazySingleton(
    () => VideoImState(
      rootState: serviceLocator.get<RootState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      videoImService: serviceLocator.get<VideoImService>(),
      authService: serviceLocator.get<AuthService>(),
      randomService: serviceLocator.get<RandomService>(),
      permissionsService: serviceLocator.get<PermissionsService>(),
      userService: serviceLocator.get<UserService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => VideoImCallState(
      rootState: serviceLocator.get<RootState>(),
      videoImState: serviceLocator.get<VideoImState>(),
      browserDetector: serviceLocator.get<BrowserDetector>(),
    ),
  );

  serviceLocator.registerFactory(
    () => VideoImAcceptCallState(
      videoImState: serviceLocator.get<VideoImState>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => VideoImService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );
}
