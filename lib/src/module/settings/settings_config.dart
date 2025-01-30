import 'package:get_it/get_it.dart';

import '../../app/route_guard/required_plugin_guard.dart';
import '../../app/route_guard/site_setting_guard.dart';
import '../../app/service/auth_service.dart';
import '../../app/service/http_service.dart';
import '../../app/service/model/route_model.dart';
import '../base/page/simple_html_page.dart';
import '../base/page/state/root_state.dart';
import '../base/service/localization_service.dart';
import '../base/service/user_service.dart';
import 'page/change_password_page.dart';
import 'page/contact_us_page.dart';
import 'page/email_notifications_settings_page.dart';
import 'page/gdpr_settings_page.dart';
import 'page/gdpr_third_party_settings_page.dart';
import 'page/preferences_page.dart';
import 'page/settings_page.dart';
import 'page/state/change_password_state.dart';
import 'page/state/contact_us_state.dart';
import 'page/state/email_notifications_settings_state.dart';
import 'page/state/gdpr_settings_state.dart';
import 'page/state/preferences_state.dart';
import 'page/state/settings_state.dart';
import 'service/change_password_service.dart';
import 'service/contact_us_service.dart';
import 'service/email_notifications_settings_service.dart';
import 'service/gdpr_settings_service.dart';
import 'service/preferences_service.dart';

final serviceLocator = GetIt.instance;

const SETTINGS_MAIN_URL = '/settings';
const SETTINGS_PRIVACY_POLICY_URL = '/privacy-policy';
const SETTINGS_TERMS_OF_USE_URL = '/terms-of-use';
const SETTINGS_GDPR_USER_DATA_URL = '/settings/user-data';
const SETTINGS_GDPR_THIRD_PARTY_URL = '/settings/third-party';
const SETTINGS_EMAIL_NOTIFICATIONS_URL = '/settings/email-notifications';
const SETTINGS_PUSH_NOTIFICATIONS_URL = '/settings/push-notifications';
const SETTINGS_CONTACT_US_URL = '/settings/contact-us';
const SETTINGS_CHANGE_PASSWORD_URL = '/settings/change-password';

List<RouteModel> getSettingsRoutes() {
  return [
    RouteModel(
      path: SETTINGS_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return SettingsPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),

    // contact us
    RouteModel(
      path: SETTINGS_CONTACT_US_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return ContactUsPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),

    // change password
    RouteModel(
      path: SETTINGS_CHANGE_PASSWORD_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return ChangePasswordPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),

    // privacy policy
    RouteModel(
      path: SETTINGS_PRIVACY_POLICY_URL,
      visibility: RouteVisibility.all,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return SimpleHtmlPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
          headerKey: 'privacy_policy_page_header',
          contentKey: 'privacy_policy_page_content',
        );
      },
    ),

    // terms of use
    RouteModel(
      path: SETTINGS_TERMS_OF_USE_URL,
      visibility: RouteVisibility.all,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return SimpleHtmlPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
          headerKey: 'tos_page_header',
          contentKey: 'tos_page_content',
        );
      },
    ),

    // email notifications
    RouteModel(
      path: SETTINGS_EMAIL_NOTIFICATIONS_URL,
      visibility: RouteVisibility.member,
      guards: [
        requiredPluginGuard('notifications'),
      ],
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return EmailNotificationsSettingsPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),

    // push notifications
    RouteModel(
      path: SETTINGS_PUSH_NOTIFICATIONS_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return PreferencesPage(
          section: 'skmobileapp_pushes',
          title: 'preferences_pushes_page_title',
        );
      },
    ),

    // GDPR user data
    RouteModel(
      path: SETTINGS_GDPR_USER_DATA_URL,
      visibility: RouteVisibility.member,
      guards: [
        requiredPluginGuard('gdpr'),
      ],
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return GdprSettingsPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),

    // GDPR third party
    RouteModel(
      path: SETTINGS_GDPR_THIRD_PARTY_URL,
      visibility: RouteVisibility.member,
      guards: [
        requiredPluginGuard('gdpr'),
        siteSettingGuard('gdprThirdPartyServices', 1),
      ],
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return GdprThirdPartySettingsPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
    ),
  ];
}

void initSettingsServiceLocator() {
  serviceLocator.registerLazySingleton(
    () => GdprSettingsService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => EmailNotificationsSettingsService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => PreferencesService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => ContactUsService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => ChangePasswordService(
      httpService: serviceLocator.get<HttpService>(),
      localizationService: serviceLocator.get<LocalizationService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => GdprSettingsState(
      gdprSettingsService: serviceLocator.get<GdprSettingsService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => EmailNotificationsSettingsState(
      emailSettingsService:
          serviceLocator.get<EmailNotificationsSettingsService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => PreferencesState(
      preferencesService: serviceLocator.get<PreferencesService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => SettingsState(
      authService: serviceLocator.get<AuthService>(),
      userService: serviceLocator.get<UserService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerFactory(
    () => ContactUsState(
      contactUsService: serviceLocator.get<ContactUsService>(),
    ),
  );

  serviceLocator.registerFactory(
    () => ChangePasswordState(
      changePasswordService: serviceLocator.get<ChangePasswordService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );
}
