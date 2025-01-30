import 'package:get_it/get_it.dart';

import '../base/page/state/app_navigator_state.dart';
import '../base/page/state/root_state.dart';
import 'page/state/admob_state.dart';

final serviceLocator = GetIt.instance;

void initAdmobServiceLocator() {
  serviceLocator.registerSingletonWithDependencies(
    () => AdmobState(
      rootState: serviceLocator.get<RootState>(),
      appNavigatorState: serviceLocator.get<AppNavigatorState>(),
    ),
    dependsOn: [
      RootState,
    ],
  );
}
