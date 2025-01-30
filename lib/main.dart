import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'main_config.dart' as mainConfig;
import 'src/app/service/app_settings_service.dart';
import 'src/app/service/logger_service.dart';
import 'src/module/base/page/error_page.dart';
import 'src/module/base/page/root_page.dart';
import 'src/module/base/page/state/root_state.dart';
import 'src/module/base/utility/theme_utility.dart';

Future<void> main() async {
  // Enable pending purchases on Android.
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  // init custom error handler
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return ErrorPage(
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );
  };

  // run the app in the isolated zone (to make possible catch async exceptions)
  runZonedGuarded<Future<Null>>(() async {
    // waiting until the app is loaded
    WidgetsFlutterBinding.ensureInitialized();

    // determine the current theme mode
    AppSettingsService.setDarkMode(isDarkMode());

    // waiting until all services are loaded
    await mainConfig.initMainServiceLocator();

    final rootPage = RootPage();
    rootPage.setRegisteredRoutes(mainConfig.getRoutes());

    runApp(WidgetsApp(
      color: Colors.white,
      builder: (context, _) => rootPage,
    ));
  }, (error, stackTrace) async {
    debugPrintStack(stackTrace: stackTrace);
    final appRootState =  mainConfig.serviceLocator.get<RootState>();
    final loggerService =  mainConfig.serviceLocator.get<LoggerService>();

    try {
      // Attempt to log error information.
      await loggerService.logError(error, stackTrace);
    } catch (_) {
      // All loggers have failed, can't do anything but ignore the exception
      // at this point. The error widget will print exception data to the
      // console.
    }
    // Ignore `in_app_purchase` plugin errors when running in PWA mode.
    //
    // This is a temporary solution that is going to be removed once a better
    // way to solve this problem is available.
    //
    // ignore: unnecessary_null_comparison
    if (kIsWeb && error != null && error.toString().contains('BillingClient')) {
      return;
    }

    // Error data should be logged only when app is running in release mode.
    if (kReleaseMode) {
      try {
        // Attempt to log error information.
        await loggerService.logError(error, stackTrace);
      } catch (_) {
        // All loggers have failed, can't do anything but ignore the exception
        // at this point. The error widget will print exception data to the
        // console.
      }
    }

    // we don't handle new errors until the active one is cleared
    if (appRootState.error != null) {
      return;
    }

    // whenever we get an error we change the root's app state
    appRootState.error = error;
    appRootState.stackTrace = stackTrace;
  });
}
