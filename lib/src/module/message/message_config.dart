import 'package:get_it/get_it.dart';

import '../../app/route_guard/required_route_params_guard.dart';
import '../../app/service/auth_service.dart';
import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../base/page/state/root_state.dart';
import '../base/service/file_uploader_service.dart';
import '../base/service/user_service.dart';
import '../base/utility/image_utility.dart';
import '../dashboard/page/state/dashboard_conversation_state.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import '../profile/service/profile_service.dart';
import 'page/message_page.dart';
import 'page/state/message_state.dart';
import 'service/message_service.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const MESSAGES_MAIN_URL = '/messages/:userId';

List<RouteModel> getMessagesRoutes() {
  return [
    RouteModel(
      path: MESSAGES_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (Map<String, dynamic> routeParams,
          Map<String, dynamic> widgetParams) {
        return MessagePage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [
        requiredRouteParamsGuard(['userId']),
      ],
    )
  ];
}

// list of available services
void initMessagesServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => MessageService(
      httpService: serviceLocator.get<HttpService>(),
      fileUploaderService: serviceLocator.get<FileUploaderService>(),
      imageUtility: serviceLocator.get<ImageUtility>(),
    ),
  );

  // state
  serviceLocator.registerFactory(
    () => MessageState(
      rootState: serviceLocator.get<RootState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      dashboardConversationState:
          serviceLocator.get<DashboardConversationState>(),
      profileService: serviceLocator.get<ProfileService>(),
      userService: serviceLocator.get<UserService>(),
      messageService: serviceLocator.get<MessageService>(),
      authService: serviceLocator.get<AuthService>(),
      randomService: serviceLocator.get<RandomService>(),
      fileUploaderService: serviceLocator.get<FileUploaderService>(),
      imageUtility: serviceLocator.get<ImageUtility>(),
    ),
  );
}
