import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../module/base/page/access_denied_page.dart';
import '../service/model/route_model.dart';

/// Allows to open the page only if the app is running in PWA mode.
RouteGuard pwaOnlyGuard() {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    return !kIsWeb ? AccessDeniedPage() : null;
  };
}
