import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/widget/distance_widget_mixin.dart';
import '../../../../base/page/widget/match_action_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/page/widget/rtl_widget_mixin.dart';
import '../../state/dashboard_tinder_state.dart';
import '../../style/tinder/dashboard_tinder_action_toolbar_widget_style.dart';

class DashboardTinderActionToolbarWidget extends StatefulWidget
    with
        RtlWidgetMixin,
        NavigationWidgetMixin,
        DistanceWidgetMixin,
        ModalWidgetMixin,
        MatchActionWidgetMixin {
  @override
  _DashboardTinderActionToolbarWidgetState createState() =>
      _DashboardTinderActionToolbarWidgetState();
}

class _DashboardTinderActionToolbarWidgetState
    extends State<DashboardTinderActionToolbarWidget> {
  late DashboardTinderState _state;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardTinderState>();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) =>
          dashboardTinderActionToolbarWidgetWrapperContainer(
        <Widget>[
          if (!_state.isPreviewMode)
            // activate preview mode
            dashboardTinderActionToolbarWidgetShowIconContainer(
              () => _state.isPreviewMode = true,
            ),
          // deactivate preview mode
          if (_state.isPreviewMode)
            dashboardTinderActionToolbarWidgetHideIconContainer(
              () => _state.isPreviewMode = false,
            ),
          // a dislike button
          dashboardTinderActionToolbarWidgetDislikeIconContainer(
            () => _state.dislikeProfile(),
          ),
          // a rewind button
          dashboardTinderActionToolbarWidgetRewindIconContainer(
            _state.activeUserIndex > 0,
            () => _state.backProfile(),
          ),
          // a like button
          dashboardTinderActionToolbarWidgetLikeIconContainer(
            () => _state.likeProfile(),
          ),
          // a profile view button
          dashboardTinderActionToolbarWidgetProfileIconContainer(
            () => _viewProfilePage(),
          ),
        ],
      ),
    );
  }

  void _viewProfilePage() {
    widget.redirectToProfilePage(
      context,
      _state.userList[_state.activeUserIndex].id,
    );
  }
}
