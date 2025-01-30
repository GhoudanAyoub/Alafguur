import 'package:get_it/get_it.dart';

import '../../app/service/model/route_model.dart';
import '../../app/service/random_service.dart';
import '../base/service/bookmark_profile_service.dart';
import '../dashboard/page/state/dashboard_user_state.dart';
import 'page/bookmark_page.dart';
import 'page/state/bookmark_state.dart';

final serviceLocator = GetIt.instance;

// list of available urls
const BOOKMARKS_MAIN_URL = '/bookmarks';

List<RouteModel> getBookmarksRoutes() {
  return [
    RouteModel(
      path: BOOKMARKS_MAIN_URL,
      visibility: RouteVisibility.member,
      pageFactory: (
        Map<String, dynamic> routeParams,
        Map<String, dynamic> widgetParams,
      ) {
        return BookmarkPage(
          routeParams: routeParams,
          widgetParams: widgetParams,
        );
      },
      guards: [],
    )
  ];
}

// list of available services
void initBookmarksServiceLocator() {
  // state
  serviceLocator.registerFactory(
    () => BookmarkState(
      dashboardUserState: serviceLocator.get<DashboardUserState>(),
      randomService: serviceLocator.get<RandomService>(),
      bookmarkProfileService: serviceLocator.get<BookmarkProfileService>(),
    ),
  );
}
