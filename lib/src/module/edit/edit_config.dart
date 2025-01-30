import 'package:get_it/get_it.dart';

import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../base/page/state/root_state.dart';
import '../base/service/file_uploader_service.dart';
import '../base/service/localization_service.dart';
import '../base/service/user_service.dart';
import '../base/utility/image_utility.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import 'page/edit_page.dart';
import 'page/edit_photo_page.dart';
import 'page/state/edit_photo_state.dart';
import 'page/state/edit_state.dart';
import 'service/edit_photo_service.dart';
import 'service/edit_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const EDIT_MAIN_URL = '/edit';
const EDIT_PHOTOS_URL = '/edit/photos';

// list of available routes
List<RouteModel> getEditRoutes() {
  return [
    RouteModel(
      path: EDIT_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          EditPage(routeParams: routeParams, widgetParams: widgetParams),
    ),
    RouteModel(
      path: EDIT_PHOTOS_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          EditPhotoPage(routeParams: routeParams, widgetParams: widgetParams),
    ),
  ];
}

// list of available services
void initEditServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => EditService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => EditPhotoService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  // state
  serviceLocator.registerLazySingleton(
    () => EditState(
      editService: serviceLocator.get<EditService>(),
      userService: serviceLocator.get<UserService>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      editPhotoState: serviceLocator.get<EditPhotoState>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => EditPhotoState(
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      rootState: serviceLocator.get<RootState>(),
      editPhotoService: serviceLocator.get<EditPhotoService>(),
      fileUploaderService: serviceLocator.get<FileUploaderService>(),
      localizationService: serviceLocator.get<LocalizationService>(),
      randomService: serviceLocator.get<RandomService>(),
      imageUtility: serviceLocator.get<ImageUtility>(),
    ),
  );
}
