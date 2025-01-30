import 'package:get_it/get_it.dart';

import 'src/app/app_config.dart';
import 'src/app/service/model/route_model.dart';
import 'src/module/module_config.dart';

final serviceLocator = GetIt.instance;

// get all routes
List<RouteModel> getRoutes() {
  return [
    ...getModuleRoutes(),
  ];
}

/// register all services
Future<void> initMainServiceLocator() async {

  // app
  initAppServiceLocator();

  // module
  initModuleServiceLocator();

  return serviceLocator.allReady();
}
