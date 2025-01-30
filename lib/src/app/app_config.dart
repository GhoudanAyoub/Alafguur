import 'package:browser_detector/browser_detector.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http_interceptor/trailing_slash_http_interceptor.dart';
import 'service/app_settings_service.dart';
import 'service/auth_service.dart';
import 'service/browser_info_service.dart';
import 'service/device_info_service.dart';
import 'service/http_service.dart';
import 'service/local_logger_service.dart';
import 'service/logger_service.dart';
import 'service/random_service.dart';
import 'service/sentry_logger_service.dart';

final serviceLocator = GetIt.instance;

/// init app services locator
void initAppServiceLocator() {

  // external
  serviceLocator.registerSingletonAsync<FirebaseApp>(() async {
    return await Firebase.initializeApp();
  });
  serviceLocator.registerSingletonAsync<FirebaseAnalytics>(
        () async {
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(
        AppSettingsService.pwaFirebaseIsAnalyticsEnabled,
      );
      return analytics;
    },
    dependsOn: [FirebaseApp], // Ensure FirebaseApp is initialized first
  );

  serviceLocator.registerLazySingleton<Dio>(
    () {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppSettingsService.apiUrl.toString(),
          connectTimeout: Duration(milliseconds: 0),
          receiveTimeout: Duration(milliseconds: 0),
        ),
      );

      // register http interceptors
      dio.interceptors.add(TrailingSlashHttpInterceptor());

      return dio;
    },
  );

  serviceLocator.registerLazySingleton(
    () => DeviceInfoPlugin(),
  );

  // browser detector
  serviceLocator.registerLazySingleton(
    () => BrowserDetector(),
  );

  // service
  serviceLocator.registerSingletonAsync(
    () => SharedPreferences.getInstance(),
  );

  serviceLocator.registerLazySingleton(
    () => fluro.FluroRouter(),
  );

  serviceLocator.registerLazySingleton(
    () => RandomService(),
  );

  serviceLocator.registerLazySingleton(
    () => BrowserInfoService(
      browserDetector: serviceLocator.get<BrowserDetector>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DeviceInfoService(
      deviceInfoPlugin: serviceLocator.get<DeviceInfoPlugin>(),
      randomService: serviceLocator.get<RandomService>(),
      browserInfoService: serviceLocator.get<BrowserInfoService>(),
    ),
  );

  serviceLocator.registerSingletonWithDependencies(
    () => AuthService(
      sharedPreferences: serviceLocator.get<SharedPreferences>(),
    ),
    dependsOn: [
      SharedPreferences,
    ],
  );

  serviceLocator.registerSingletonWithDependencies(
    () => HttpService(
      dio: serviceLocator.get<Dio>(),
      authService: serviceLocator.get<AuthService>(),
      randomService: serviceLocator.get<RandomService>(),
      browserDetector: serviceLocator.get<BrowserDetector>(),
    ),
    dependsOn: [
      AuthService,
    ],
  );

  serviceLocator.registerSingletonAsync(
    () async {
      final localLogger = LocalLoggerService(
        httpService: serviceLocator.get<HttpService>(),
        deviceInfoService: serviceLocator.get<DeviceInfoService>(),
      );

      LoggerService logger;

      switch (AppSettingsService.loggerType) {
        case LoggerType.sentry:
          logger = AppSettingsService.canUseSentry
              ? SentryLoggerService(
                  dsn: AppSettingsService.sentryDsn,
                  browserInfoService: serviceLocator.get<BrowserInfoService>(),
                )
              : localLogger;
          break;

        default:
          logger = localLogger;
      }

      await logger.initialize();

      return logger;
    },
    dependsOn: [
      HttpService,
    ],
  );
}
