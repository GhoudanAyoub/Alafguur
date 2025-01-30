import 'package:browser_detector/browser_detector.dart';
import 'package:get_it/get_it.dart';

import '../../app/route_guard/pwa_only_guard.dart';
import '../../app/service/model/route_model.dart';
import 'page/installation_guide_page.dart';
import 'page/state/installation_guide_state.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const INSTALLATION_GUIDE_MAIN_URL = '/installation-guide';

List<RouteModel> getInstallationGuideRoutes() {
  return [
    RouteModel(
      path: INSTALLATION_GUIDE_MAIN_URL,
      visibility: RouteVisibility.all,
      pageFactory: (Map<String, dynamic> routeParams, Map<String, dynamic> widgetParams) {
        return InstallationGuidePage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [
        pwaOnlyGuard(),
      ],
    )
  ];
}

// list of available services
void initInstallationGuideServiceLocator() {
  // state
  serviceLocator.registerFactory(
    () => InstallationGuideState(
      browserDetector: serviceLocator.get<BrowserDetector>(),
    ),
  );
}
