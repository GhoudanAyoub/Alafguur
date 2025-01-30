import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

import '../../base_config.dart';
import 'root_state.dart';

part 'app_navigator_state.g.dart';

class AppNavigatorState = _AppNavigatorState with _$AppNavigatorState;

abstract class _AppNavigatorState extends NavigatorObserver with Store {
  final RootState rootState;
  // final FirebaseAnalytics firebaseAnalytics;

  static const _FLUSHBAR_ROUTE_NAME = '/flushbarRoute';

  /// Current page name.
  @observable
  String? currentPageName = '';

  /// Routes in this list won't be set to [currentPageName].
  List<String> _ignoredRoutes = [
    _FLUSHBAR_ROUTE_NAME,
  ];

  _AppNavigatorState({
    required this.rootState
    // required this.firebaseAnalytics,
  });

  @action
  @override
  void didPush(Route route, Route? previousRoute) {
    // route name can be null if something like a modal window or an alert is
    // pushed onto the navigation stack.
    if (route.settings.name != null) {
      if (_ignoredRoutes.contains(route.settings.name)) {
        return;
      }

      currentPageName = route.settings.name;

      // firebaseAnalytics.logEvent(
      //   name: 'page_view',
      //   parameters: {'page_location': currentPageName ?? 'unknown_page'},
      // );
    }
  }

  @action
  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      if (_ignoredRoutes.contains(previousRoute.settings.name)) {
        return;
      }

      currentPageName = previousRoute.settings.name;

      return;
    }

    currentPageName = BASE_MAIN_URL;
  }
}
