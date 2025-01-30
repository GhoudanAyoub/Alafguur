import 'package:browser_detector/browser_detector.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/service/app_settings_service.dart';
import '../../app/service/auth_service.dart';
import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../base/base_config.dart';
import '../base/page/state/device_info_state.dart';
import '../base/page/state/firebase_state.dart';
import '../base/page/state/page_visibility_state.dart';
import '../base/page/state/root_state.dart';
import '../base/service/localization_service.dart';
import '../base/service/user_service.dart';
import '../guest/page/state/guest_state.dart';
import '../payment/page/state/payment_in_app_purchase_state.dart';
import '../payment/page/state/payment_state.dart';
import '../video_im/page/state/video_im_state.dart';
import 'page/dashboard_page.dart';
import 'page/state/dashboard_conversation_state.dart';
import 'page/state/dashboard_hot_list_state.dart';
import 'page/state/dashboard_menu_state.dart';
import 'page/state/dashboard_profile_state.dart';
import 'page/state/dashboard_search_state.dart';
import 'page/state/dashboard_state.dart';
import 'page/state/dashboard_tinder_state.dart';
import 'page/state/dashboard_user_state.dart';
import 'service/dashboard_conversation_service.dart';
import 'service/dashboard_hot_list_service.dart';
import 'service/dashboard_matched_user_service.dart';
import 'service/dashboard_search_service.dart';
import 'service/dashboard_tinder_service.dart';
import 'service/dashboard_user_service.dart';

final serviceLocator = GetIt.instance;

// list of available routes
List<RouteModel> getDashboardRoutes() {
  return [
    RouteModel(
      path: BASE_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) =>
          DashboardPage(routeParams: routeParams, widgetParams: widgetParams),
    ),
  ];
}

// list of available services
void initDashboardServiceLocator() {
  // service
  serviceLocator.registerLazySingleton(
    () => DashboardUserService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardHotListService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardConversationService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardMatchedUserService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardSearchService(
      httpService: serviceLocator.get<HttpService>(),
      userService: serviceLocator.get<UserService>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardTinderService(
      httpService: serviceLocator.get<HttpService>(),
      userService: serviceLocator.get<UserService>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  // state
  serviceLocator.registerLazySingleton(
    () => DashboardUserState(
      userService: serviceLocator.get<UserService>(),
      rootState: serviceLocator.get<RootState>(),
      dashboardUserService: serviceLocator.get<DashboardUserService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardConversationState(
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      rootState: serviceLocator.get<RootState>(),
      userService: serviceLocator.get<UserService>(),
      dashboardConversationService:
          serviceLocator.get<DashboardConversationService>(),
      dashboardMatchedUserService:
          serviceLocator.get<DashboardMatchedUserService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardState(
      localizationService: serviceLocator.get<LocalizationService>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
      browserDetector: serviceLocator.get<BrowserDetector>(),
      rootState: serviceLocator.get<RootState>(),
      firebaseState: serviceLocator.get<FirebaseState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      videoImState: serviceLocator.get<VideoImState>(),
      dashboardConversationState:
          serviceLocator.get<DashboardConversationState>(),
      deviceInfoState: serviceLocator.get<DeviceInfoState>(),
      pageVisibilityState: serviceLocator.get<PageVisibilityState>(),
      firebaseVapidKey: AppSettingsService.vapidKey,
      guestState: serviceLocator.get<GuestState>(),
      dashboardMenuState: serviceLocator.get<DashboardMenuState>(),
      inAppPurchaseState: serviceLocator.get<PaymentInAppPurchaseState>(),
      paymentState: serviceLocator.get<PaymentState>(),
      userService: serviceLocator.get<UserService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardHotListState(
      rootState: serviceLocator.get<RootState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      authService: serviceLocator.get<AuthService>(),
      dashboardHotListService: serviceLocator.get<DashboardHotListService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardSearchState(
      rootState: serviceLocator.get<RootState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      authService: serviceLocator.get<AuthService>(),
      dashboardSearchService: serviceLocator.get<DashboardSearchService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardProfileState(
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      rootState: serviceLocator.get<RootState>(),
      paymentState: serviceLocator.get<PaymentState>(),
      guestState: serviceLocator.get<GuestState>(),
      inAppPurchaseState: serviceLocator.get<PaymentInAppPurchaseState>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardTinderState(
      rootState: serviceLocator.get<RootState>(),
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      dashboardTinderService: serviceLocator.get<DashboardTinderService>(),
      dashboardState: serviceLocator.get<DashboardState>(),
      randomService: serviceLocator.get<RandomService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardMenuState(
      rootState: serviceLocator.get<RootState>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
      dashboardConversationState:
          serviceLocator.get<DashboardConversationState>(),
    ),
  );
}
