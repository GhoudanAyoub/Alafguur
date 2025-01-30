import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/analytic_widget_mixin.dart';
import '../../../../base/page/widget/skeleton/card_list_skeleton_widget.dart';
import '../../../../payment/page/widget/payment_access_denied_widget.dart';
import '../../state/dashboard_search_state.dart';
import '../../style/search/dashboard_search_widget_style.dart';
import 'dashboard_search_filter_widget.dart';
import 'dashboard_search_not_found_widget.dart';
import 'dashboard_search_skeleton_widget.dart';
import 'dashboard_search_user_list_widget.dart';

class DashboardSearchWidget extends StatefulWidget with AnalyticWidgetMixin {
  @override
  _DashboardSearchWidgetState createState() => _DashboardSearchWidgetState();
}

class _DashboardSearchWidgetState extends State<DashboardSearchWidget> {
  late final DashboardSearchState _state;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardSearchState>();
    _state.init();

    // we need to restore the scroll position every time when the page is active
    _scrollController =
        ScrollController(initialScrollOffset: _state.scrollOffset);
    _scrollController
      ..addListener(() => _state.scrollOffset = _scrollController.offset);

    widget.logViewList('browse-user-list');
  }

  @override
  void dispose() {
    _state.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => Material(
        color: transparentColor(),
        child: !_state.isPageLoaded
            ? DashboardSearchSkeletonWidget()
            : _userListPage(),
      ),
    );
  }

  /// display a user search page
  Widget _userListPage() {
    // check permissions
    if (!_state.permission!.isAllowed)
      return PaymentAccessDeniedWidget(
        showUpgradeButton: _state.permission?.isPromoted == true,
      );

    return dashboardSearchWidgetWrapperContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // search filters
          DashboardSearchFilterWidget(),

          // display an inner skeleton (when we are searching users)
          if (_state.isUserListLoading)
            CardListSkeletonWidget(
              itemCount: 4,
            ),

          // not found
          if (_state.userList.isEmpty && !_state.isUserListLoading)
            DashboardSearchNotFoundWidget(),

          // a user list
          if (_state.userList.isNotEmpty && !_state.isUserListLoading)
            DashboardSearchUserListWidget(
              scrollController: _scrollController,
              state: _state,
            ),
        ],
      ),
    );
  }
}
