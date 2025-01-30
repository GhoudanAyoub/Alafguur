import 'package:browser_detector/browser_detector.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_config.dart';
import '../../app/service/app_settings_service.dart';
import '../../app/service/auth_service.dart';
import '../../app/service/device_info_service.dart';
import '../../app/service/http_service.dart';
import '../../app/service/logger_service.dart';
import '../../app/service/random_service.dart';
import 'delegate/localization_delegate.dart';
import 'page/state/app_navigator_state.dart';
import 'page/state/device_info_state.dart';
import 'page/state/error/complete_account_state.dart';
import 'page/state/error/complete_profile_state.dart';
import 'page/state/error/verify_email_state.dart';
import 'page/state/error/verify_phone_code_state.dart';
import 'page/state/error/verify_phone_number_state.dart';
import 'page/state/firebase_state.dart';
import 'page/state/flag_content_state.dart';
import 'page/state/form/date_form_element_state.dart';
import 'page/state/form/form_builder_state.dart';
import 'page/state/form/google_location_form_element_state.dart';
import 'page/state/form/select_form_element_state.dart';
import 'page/state/match_action_state.dart';
import 'page/state/page_visibility_state.dart';
import 'page/state/root_state.dart';
import 'page/state/user_avatar_state.dart';
import 'page/widget/form/form_builder_widget.dart';
import 'root_page_bootstrapper.dart';
import 'service/bookmark_profile_service.dart';
import 'service/complete_account_service.dart';
import 'service/complete_profile_service.dart';
import 'service/email_verification_service.dart';
import 'service/file_uploader_service.dart';
import 'service/firebase_auth_service.dart';
import 'service/firebase_service.dart';
import 'service/flag_content_service.dart';
import 'service/form_validation_service.dart';
import 'service/google_location_service.dart';
import 'service/localization_service.dart';
import 'service/match_action_service.dart';
import 'service/permissions_service.dart';
import 'service/phone_verification_service.dart';
import 'service/root_service.dart';
import 'service/user_service.dart';
import 'utility/debug_logger_utility.dart';
import 'utility/image_utility.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const BASE_MAIN_URL = '/';
const BASE_PROFILE_URL = '/profiles/:id';
const BASE_PAYMENT_URL = '/upgrades';

// list of available services
void initBaseServiceLocator() {
  final isPwa = kIsWeb && Uri.base.queryParameters['pwa'] != null;

  // service
  serviceLocator.registerLazySingleton(
        () => RootService(
      httpService: serviceLocator.get<HttpService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => LocalizationService(
      httpService: serviceLocator.get<HttpService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => GoogleLocationService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => CompleteProfileService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => BookmarkProfileService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => MatchActionService(
      httpService: serviceLocator.get<HttpService>(),
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => EmailVerificationService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => PhoneVerificationService(
      httpService: serviceLocator.get<HttpService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => CompleteAccountService(
      httpService: serviceLocator.get<HttpService>(),
      userService: serviceLocator.get<UserService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => UserService(
      httpService: serviceLocator.get<HttpService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => FormValidationService(
      httpService: serviceLocator.get<HttpService>(),
      authService: serviceLocator.get<AuthService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => FileUploaderService(
      httpService: serviceLocator.get<HttpService>(),
      localizationService: serviceLocator.get<LocalizationService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => PermissionsService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => FirebaseAuthService(
      twitterConsumerKey: AppSettingsService.socialAuthTwitterConsumerKey,
      twitterConsumerSecret: AppSettingsService.socialAuthTwitterConsumerSecret,
      randomService: serviceLocator.get<RandomService>(),
      appleConnectClientId: AppSettingsService.socialAuthAppleClientId,
      apiProtocol: AppSettingsService.apiProtocol,
      apiDomain: AppSettingsService.apiDomain,
      bundleName: AppSettingsService.bundleName,
      isPwaMode: isPwa,
    ),
  );

  serviceLocator.registerLazySingleton(
        () => FlagContentService(
      httpService: serviceLocator.get<HttpService>(),
    ),
  );

  serviceLocator.registerSingletonWithDependencies(
        () => FirebaseService(
      httpService: serviceLocator.get<HttpService>(),
    ),
    dependsOn: [
      HttpService,
    ],
  );

  // state

  // Should be above the RootState registration because otherwise GetIt will not
  // find the FirebaseState among the registered types and throw an error since
  // the RootState depends on it.
  serviceLocator.registerSingletonAsync(
        () async {
      final firebaseService = FirebaseState(
        firebaseService: serviceLocator.get<FirebaseService>(),
      );

      await firebaseService.init();

      return firebaseService;
    },
    dependsOn: [
      FirebaseService,
    ],
  );

  serviceLocator.registerSingletonAsync<RootState>(
        () async {
      final rootState = RootState(
        rootService: serviceLocator.get<RootService>(),
        authService: serviceLocator.get<AuthService>(),
        loggerService: serviceLocator.get<LoggerService>(),
        debugLoggerUtility: serviceLocator.get<DebugLoggerUtility>(),
        firebaseState: serviceLocator.get<FirebaseState>(),
        deviceInfoState: serviceLocator.get<DeviceInfoState>(),
        isPwaMode: isPwa,
      );

      await rootState.loadResources();

      return rootState;
    },
    dependsOn: [
      HttpService,
      FirebaseState,
      LoggerService,
    ],
  );

  serviceLocator.registerFactory(
        () => FormBuilderState(
      formValidationService: serviceLocator.get<FormValidationService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerFactory(
        () => CompleteProfileState(
      rootState: serviceLocator.get<RootState>(),
      completeProfileService: serviceLocator.get<CompleteProfileService>(),
      userService: serviceLocator.get<UserService>(),
    ),
  );

  serviceLocator.registerFactory(
        () => CompleteAccountState(
      rootState: serviceLocator.get<RootState>(),
      completeAccountService: serviceLocator.get<CompleteAccountService>(),
    ),
  );

  serviceLocator.registerFactory(
        () => SelectFormElementState(),
  );

  serviceLocator.registerFactory(
        () => GoogleLocationFormElementState(
      googleLocationService: serviceLocator.get<GoogleLocationService>(),
    ),
  );

  serviceLocator.registerFactory(
        () => DateFormElementState(),
  );

  serviceLocator.registerFactory(
        () => VerifyEmailState(
      emailVerificationService: serviceLocator.get<EmailVerificationService>(),
      userService: serviceLocator.get<UserService>(),
      authService: serviceLocator.get<AuthService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerFactory(
        () => VerifyPhoneNumberState(
      phoneVerificationService: serviceLocator.get<PhoneVerificationService>(),
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerFactory(
        () => VerifyPhoneCodeState(
      phoneVerificationService: serviceLocator.get<PhoneVerificationService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => UserAvatarState(
      rootState: serviceLocator.get<RootState>(),
    ),
  );

  serviceLocator.registerFactory(
        () => FlagContentState(
      flagContentService: serviceLocator.get<FlagContentService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => MatchActionState(
      matchActionService: serviceLocator.get<MatchActionService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => DeviceInfoState(
      deviceInfoService: serviceLocator.get<DeviceInfoService>(),
    ),
  );

  serviceLocator.registerLazySingleton(
        () => PageVisibilityState(),
  );

  serviceLocator.registerLazySingleton(
        () => AppNavigatorState(
      rootState: serviceLocator.get<RootState>(),
      // firebaseAnalytics: serviceLocator.get<FirebaseAnalytics>(),
    ),
  );

  // delegate
  serviceLocator.registerLazySingleton(
        () => LocalizationDelegate(
      localizationService: serviceLocator.get<LocalizationService>(),
    ),
  );

  // bootstrapper
  serviceLocator.registerLazySingleton(
        () => RootPageBootstrapper(
      router: serviceLocator.get<FluroRouter>(),
      localizationDelegate: serviceLocator.get<LocalizationDelegate>(),
      appNavigatorState: serviceLocator.get<AppNavigatorState>(),
      appName: AppSettingsService.appName,
      browserDetector: serviceLocator.get<BrowserDetector>(),
    ),
  );

  // widget
  serviceLocator.registerFactory(
        () => FormBuilderWidget(
      state: serviceLocator.get<FormBuilderState>(),
    ),
  );

  // utility
  serviceLocator.registerLazySingleton(
        () => DebugLoggerUtility(),
  );

  serviceLocator.registerLazySingleton(
        () => ImageUtility(),
  );
}
