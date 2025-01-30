import 'package:get_it/get_it.dart';

import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../base/page/state/root_state.dart';
import '../base/service/file_uploader_service.dart';
import '../base/service/localization_service.dart';
import '../base/service/user_service.dart';
import '../base/utility/image_utility.dart';
import 'page/join_finalize_page.dart';
import 'page/join_initial_page.dart';
import 'page/state/join_finalize_state.dart';
import 'page/state/join_initial_avatar_state.dart';
import 'page/state/join_initial_state.dart';
import 'route_guard/join_initial_form_values_guard.dart';
import 'service/join_finalize_service.dart';
import 'service/join_initial_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const JOIN_MAIN_URL = '/join';
const JOIN_FINALIZE_URL = '/join/finalize';

// list of available routes
List<RouteModel> getJoinRoutes() {
  return [
    RouteModel(
      path: JOIN_MAIN_URL,
      visibility: RouteVisibility.guest,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return JoinInitialPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),
    RouteModel(
      path: JOIN_FINALIZE_URL,
      visibility: RouteVisibility.guest,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return JoinFinalizePage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [
        joinInitialFormValuesGuard(),
      ],
    ),
  ];
}

// list of available services
void initJoinServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => JoinInitialService(
      httpService: serviceLocator.get<HttpService>(),
      localizationService: serviceLocator.get<LocalizationService>(),
      userService: serviceLocator.get<UserService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => JoinFinalizeService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerFactory(
    () => JoinInitialAvatarState(
      fileUploaderService: serviceLocator.get<FileUploaderService>(),
      rootState: serviceLocator.get<RootState>(),
      localizationService: serviceLocator.get<LocalizationService>(),
      imageUtility: serviceLocator.get<ImageUtility>(),
    ),
  );

  serviceLocator.registerFactory(
    () => JoinInitialState(
      joinInitialService: serviceLocator.get<JoinInitialService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerFactory(
    () => JoinFinalizeState(
      joinFinalizeService: serviceLocator.get<JoinFinalizeService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );
}
