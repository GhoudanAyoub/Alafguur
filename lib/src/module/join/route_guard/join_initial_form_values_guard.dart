import 'package:get_it/get_it.dart';

import '../../../app/service/model/route_model.dart';
import '../../base/page/access_denied_page.dart';
import '../service/join_initial_service.dart';

/// Checks whether the provided widget parameters contain all the required
/// initial join form keys.
///
/// The [JoinInitialService.guardFormElementsKeys] property defines the list of
/// required keys.
RouteGuard joinInitialFormValuesGuard() {
  return (
    RouteModel route,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    final service = serviceLocator.get<JoinInitialService>();

    final missingKeys = service.guardFormElementsKeys.where(
      (key) => !widgetParams.containsKey(key),
    );

    return missingKeys.isNotEmpty ? AccessDeniedPage() : null;
  };
}
