import 'package:get_it/get_it.dart';

import '../../module/base/page/error_page.dart';
import '../../module/base/page/state/root_state.dart';
import '../service/model/route_model.dart';

RouteGuard errorGuard() {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    final rootState = serviceLocator.get<RootState>();
    if (rootState.error != null) {
      return ErrorPage(
        error: rootState.error,
        stackTrace: rootState.stackTrace,
        isAppLoaded: rootState.isApplicationLoaded,
      );
    }

    return null;
  };
}
