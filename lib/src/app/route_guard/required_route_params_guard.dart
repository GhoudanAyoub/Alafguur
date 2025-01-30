import 'package:get_it/get_it.dart';

import '../../module/base/page/access_denied_page.dart';
import '../service/model/route_model.dart';

typedef RequiredRouteParamsGuardValidatorCallback = bool Function(
  String,
  dynamic,
);

RouteGuard requiredRouteParamsGuard(
  List<String> requiredParams, {
  RequiredRouteParamsGuardValidatorCallback? paramValidatorCallback,
}) {
  return (
    RouteModel model,
    Map<String, dynamic> routeParams,
    Map<String, dynamic> widgetParams,
    GetIt serviceLocator,
  ) {
    if (routeParams.isEmpty && requiredParams.isNotEmpty) {
      return AccessDeniedPage();
    }

    final isParamValid = (String key) {
      if (!routeParams.containsKey(key)) {
        return false;
      }

      // additional check
      if (paramValidatorCallback != null) {
        return paramValidatorCallback(key, routeParams[key]);
      }

      bool isValid = true;
      final List routeValue = routeParams[key];
      routeValue.forEach((dynamic value) {
        if (value == null || value == '') {
          isValid = false;
        }
      });

      return isValid;
    };

    // make sure that all required params are present and not empty
    if (!requiredParams.every(isParamValid)) {
      return AccessDeniedPage();
    }

    return null;
  };
}
