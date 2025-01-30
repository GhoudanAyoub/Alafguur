import '../../module/base/page/state/root_state.dart';
import 'package:get_it/get_it.dart';

import '../../module/base/page/access_denied_page.dart';
import '../service/model/route_model.dart';

/// Allows to open the page only if the given plugin is activated.
RouteGuard requiredPluginGuard(String plugin) {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    final rootState = serviceLocator.get<RootState>();

    return rootState.isPluginAvailable(plugin) ? null : AccessDeniedPage();
  };
}
