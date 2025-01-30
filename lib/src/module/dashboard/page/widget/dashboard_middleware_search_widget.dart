import 'search/dashboard_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'dashboard_navigation_widget_mixin.dart';
import 'hot_list/dashboard_hot_list_widget.dart';
import 'tinder/dashboard_tinder_widget.dart';
import '../state/dashboard_menu_state.dart';

class DashboardMiddlewareSearchWidget extends StatelessWidget
    with DashboardNavigationWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => _getActiveWidget(),
    );
  }

  Widget _getActiveWidget() {
    switch (getActiveSubPageName(
      checkMainPage: false,
    )) {
      case DashboardSubPagesEnum.hotList:
        return DashboardHotListWidget();

      case DashboardSubPagesEnum.tinder:
        return DashboardTinderWidget();

      default:
        return DashboardSearchWidget();
    }
  }
}
