import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/widget/analytic_widget_mixin.dart';
import '../../../../payment/page/widget/payment_access_denied_widget.dart';
import '../../state/dashboard_tinder_state.dart';
import '../../style/tinder/dashboard_tinder_widget_style.dart';
import 'dashboard_tinder_loading_widget.dart';
import 'dashboard_tinder_location_issue_widget.dart';
import 'dashboard_tinder_user_card_widget.dart';

class DashboardTinderWidget extends StatefulWidget with AnalyticWidgetMixin {
  @override
  _DashboardTinderWidgetState createState() => _DashboardTinderWidgetState();
}

class _DashboardTinderWidgetState extends State<DashboardTinderWidget> {
  late DashboardTinderState _state;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardTinderState>();
    _state.init();

    widget.logViewList('tinder-user-list');
  }

  @override
  void dispose() {
    super.dispose();
    _state.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => dashboardTinderWidgetWrapperContainer(
        _state.isPageLoading
            ? DashboardTinderLoadingWidget()
            : _state.isLocationNotDefined
                ? DashboardTinderLocationIssueWidget()
                : tinderPage(),
      ),
    );
  }

  Widget tinderPage() {
    // search is not allowed
    if (_state.isSearchNotAllowed) {
      return PaymentAccessDeniedWidget(
        showUpgradeButton: _state.searchPermission?.isPromoted == true,
      );
    }

    // tinder cards
    return DashboardTinderUserCardWidget();
  }
}
