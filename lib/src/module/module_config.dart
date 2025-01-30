import 'package:get_it/get_it.dart';

import '../app/service/app_settings_service.dart';
import '../app/service/model/route_model.dart';
import 'admob/admob_config.dart';
import 'base/base_config.dart';
import 'bookmark/bookmark_config.dart';
import 'compatible_user/compatible_user_config.dart';
import 'dashboard/dashboard_config.dart';
import 'edit/edit_config.dart';
import 'guest/guest_config.dart';
import 'installation_guide/installation_guide_config.dart';
import 'join/join_config.dart';
import 'login/login_config.dart';
import 'message/message_config.dart';
import 'payment/payment_config.dart';
import 'profile/profile_config.dart';
import 'reset_password/reset_password_config.dart';
import 'settings/settings_config.dart';
import 'video_im/video_im_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final serviceLocator = GetIt.instance;

/// get modules routes
List<RouteModel> getModuleRoutes() {
  return [
    ...getDashboardRoutes(),
    ...getLoginRoutes(),
    ...getJoinRoutes(),
    ...getResetPasswordRoutes(),
    ...getProfileRoutes(),
    ...getInstallationGuideRoutes(),
    ...getEditRoutes(),
    ...getSettingsRoutes(),
    ...getMessagesRoutes(),
    ...getCompatibleUsersRoutes(),
    ...getBookmarksRoutes(),
    ...getGuestsRoutes(),
    ...getPaymentRoutes(),
  ];
}

/// init module services locator
void initModuleServiceLocator() {
  // base
  initBaseServiceLocator();

  // admob
  initAdmobServiceLocator();

  // dashboard
  initDashboardServiceLocator();

  // login
  initLoginServiceLocator();

  // join
  initJoinServiceLocator();

  // reset password
  initResetPasswordServiceLocator();

  // profile
  initProfileServiceLocator();

  // video im
  initVideoImServiceLocator();

  // edit
  initEditServiceLocator();

  // installation guide
  initInstallationGuideServiceLocator();

  // settings
  initSettingsServiceLocator();

  // messages
  initMessagesServiceLocator();

  // compatible users
  initCompatibleUsersServiceLocator();

  // bookmarks
  initBookmarksServiceLocator();

  // guests
  initGuestsServiceLocator();

  // payments
  initPaymentServiceLocator();

}
