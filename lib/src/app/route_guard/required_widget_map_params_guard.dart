import 'package:get_it/get_it.dart';

import '../../module/base/page/access_denied_page.dart';
import '../service/model/route_model.dart';

typedef RequiredWidgetMapParamsGuardValidatorCallback = bool Function(
  String,
  dynamic,
);

RouteGuard requiredWidgetMapParamsGuard(
  List<String> requiredParams, {
  RequiredWidgetMapParamsGuardValidatorCallback? paramValidatorCallback,
}) {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    final isParamValid = (String key) {
      if (!widgetParams.containsKey(key)) {
        return false;
      }

      // additional check
      if (paramValidatorCallback != null) {
        return paramValidatorCallback(key, widgetParams[key]);
      }

      return true;
    };

    // make sure that all required params are present and not empty
    if (!requiredParams.every(isParamValid)) {
      return AccessDeniedPage();
    }

    return null;
  };
}
