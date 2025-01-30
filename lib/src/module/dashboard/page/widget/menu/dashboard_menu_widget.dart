import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../state/dashboard_menu_state.dart';
import '../../style/menu/dashboard_menu_widget_style.dart';
import '../dashboard_navigation_widget_mixin.dart';

class DashboardMenuWidget extends StatelessWidget
    with DashboardNavigationWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => dashboardMenuWidgetIconsContainer(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // a profile icon
            dashboardMenuWidgetProfileIconContainer(
              isDashboardProfilePageActive(),
              () => navigateDashboardToProfilePage(),
            ),

            // a search middleware (with sub pages)
            dashboardMenuWidgetSearchMiddlewareIconsWrapperContainer(
              [
                // an animation container
                if (isDashboardMiddlewareSearchPageActive())
                  dashboardMenuWidgetSearchMiddlewareAnimationContainer(
                    context,
                    getSubPageMenuElementOffset(),
                  ),

                Row(
                  children: [
                    // a hot list icon
                    if (isHotListSubPageAllowed)
                      dashboardMenuWidgetHotListIconContainer(
                        getActiveSubPageName() == DashboardSubPagesEnum.hotList,
                        () => navigateDashboardToHotListSubPage(),
                      ),

                    // a tinder cards icon
                    if (isTinderCardsSubPageAllowed)
                      dashboardMenuWidgetTinderCardsIconContainer(
                        getActiveSubPageName() == DashboardSubPagesEnum.tinder,
                        () => navigateDashboardToTinderCardsSubPage(),
                      ),

                    // a browse icon
                    if (isBrowseSubPageAllowed)
                      dashboardMenuWidgetBrowseIconContainer(
                        getActiveSubPageName() == DashboardSubPagesEnum.browse,
                        () => navigateDashboardToBrowseSubPage(),
                      ),
                  ],
                ),
              ],
            ),

            // a conversation icon
            dashboardMenuWidgetConversationIconContainer(
              context,
              isDashboardConversationPageActive(),
              newMessages || newMatchedUsers,
              () => navigateDashboardToConversationPage(),
            ),
          ],
        ),
      ),
    );
  }
}
