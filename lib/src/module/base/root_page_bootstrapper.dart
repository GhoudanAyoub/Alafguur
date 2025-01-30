import 'package:browser_detector/browser_detector.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../app/route_guard/auth_guard.dart';
import '../../app/route_guard/error_guard.dart';
import '../../app/service/app_settings_service.dart';
import '../../app/service/model/route_model.dart';
import 'base_config.dart';
import 'delegate/localization_delegate.dart';
import 'page/state/app_navigator_state.dart';

class RootPageBootstrapper {
  final fluro.FluroRouter router;
  final LocalizationDelegate localizationDelegate;
  final AppNavigatorState appNavigatorState;
  final String appName;
  final BrowserDetector browserDetector;

  RootPageBootstrapper({
    required this.router,
    required this.localizationDelegate,
    required this.appNavigatorState,
    required this.appName,
    required this.browserDetector,
  });

  /// get initial route
  ///
  /// indicates which page should be loaded firstly
  String getInitialRoute() {
    return BASE_MAIN_URL;
  }

  TargetPlatform? getInitialPlatform() {
    if (browserDetector.browser.isSafari) {
      return TargetPlatform.iOS;
    }
    return null;
  }

  /// register both core and features routes
  ///
  /// it also has some auth checks
  fluro.FluroRouter initRouter(List<RouteModel> routes) {
    // register routes
    routes.forEach(
      (route) {
        // prevent the default route (/) from being added multiple times
        if (route.path == Navigator.defaultRouteName &&
            router.match(route.path) != null) {
          return;
        }

        router.define(
          route.path,
          handler: fluro.Handler(
            handlerFunc: (
              BuildContext? context,
              Map<String, List<String>> routeParams,
            ) {
              final arguments = ModalRoute.of(context!)!.settings.arguments;

              // extract widget params
              final widgetParams = arguments != null
                  ? Map<String, dynamic>.from(arguments as Map)
                  : <String, dynamic>{};

              // combine the default guards with the custom ones
              final guardList = [errorGuard(), authGuard(), ...route.guards];

              // call a chain of the route guards
              final guardWidget = guardList.fold<Widget?>(
                null,
                (Widget? prevValue, RouteGuard guard) =>
                    prevValue ??
                    guard(route, routeParams, widgetParams, GetIt.instance),
              );

              return guardWidget ??
                  route.pageFactory(routeParams, widgetParams);
            },
          ),
          transitionType: fluro.TransitionType.material,
        );
      },
    );

    // Display NotFoundWidget if the route was not found.
    //
    // There is no default not found handler in Fluro, which results in an error
    // when running in sound null safety mode. This line mitigates this error.
    router.notFoundHandler = fluro.Handler(
      type: HandlerType.function,
      handlerFunc: (
        BuildContext? context,
        Map<String, List<String>> parameters,
      ) =>
          null,
    );

    return router;
  }

  String getAppTitle() {
    return appName;
  }

  LocalizationDelegate getLocalizationDelegate() {
    return localizationDelegate;
  }

  /// we let the application know that we accept any locale
  ///
  /// our api returns default translations for unknown languages (that's why we accept everything)
  LocaleResolutionCallback getLocaleResolutionCallback() {
    return (Locale? locale, Iterable<Locale> supportedLocales) {
      // we only need to get a language code ("en", "es", etc)
      // all other parts should be skipped like "en_US"
      return Locale(locale!.languageCode.substring(0, 2));
    };
  }

  /// Get navigator observers.
  List<NavigatorObserver> getNavigatorObservers() {
    final observers = [
      NavigationHistoryObserver(),
      appNavigatorState,
    ];

    if (AppSettingsService.canUseSentry) {
      observers.add(SentryNavigatorObserver());
    }

    return observers;
  }
}
