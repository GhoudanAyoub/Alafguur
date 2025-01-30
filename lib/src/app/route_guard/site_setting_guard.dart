import 'package:get_it/get_it.dart';

import '../../module/base/page/access_denied_page.dart';
import '../../module/base/page/state/root_state.dart';
import '../service/model/route_model.dart';

/// Allows to open the page only if the site setting identified by the
/// [settingName] of type [T] exists or equals to [value] (if provided).
RouteGuard siteSettingGuard<T>(String settingName, [T? value]) {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    final rootState = serviceLocator.get<RootState>();
    final settingValue = rootState.getSiteSetting<T?>(settingName, null);

    final showPage =
        value == null ? settingValue != null : settingValue == value;

    return showPage ? null : AccessDeniedPage();
  };
}
