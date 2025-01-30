import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/widget/distance_widget_mixin.dart';
import '../../../../base/page/widget/match_action_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/page/widget/rtl_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../state/dashboard_tinder_state.dart';
import '../../style/tinder/dashboard_tinder_user_preview_widget_style.dart';
import 'dashboard_tinder_action_toolbar_widget.dart';
import 'dashboard_tinder_filter_popup_widget.dart';

class DashboardTinderUserPreviewWidget extends StatefulWidget
    with
        RtlWidgetMixin,
        NavigationWidgetMixin,
        DistanceWidgetMixin,
        ModalWidgetMixin,
        PaymentPermissionWidgetMixin,
        MatchActionWidgetMixin {
  @override
  _DashboardTinderUserPreviewWidgetState createState() =>
      _DashboardTinderUserPreviewWidgetState();
}

class _DashboardTinderUserPreviewWidgetState
    extends State<DashboardTinderUserPreviewWidget> {
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
          dashboardTinderUserPreviewWrapperWidgetContainer(
        Column(
          children: [
            // a user avatar
            dashboardTinderUserPreviewWidgetAvatarContainer(
              _state.userList[_state.activeUserIndex],
            ),

            // a user name
            dashboardTinderUserPreviewWidgetUserNameContainer(
              _state.userList[_state.activeUserIndex],
              context,
              distance: _state.userList[_state.activeUserIndex].distance != null
                  ? widget.getDistance(
                      _state.userList[_state.activeUserIndex],
                      context,
                    )
                  : null,
              isFiltersAllowed: _state.isFiltersAllowed,
              filtersCallback: _showFilters,
            ),

            // a compatibility
            if (_state.userList[_state.activeUserIndex].compatibility != null)
              dashboardTinderUserPreviewWidgetUserCompatibilityContainer(
                _state.userList[_state.activeUserIndex],
                context,
                LocalizationService.of(context).t('compatibility'),
              ),

            // a user desc
            if (_state.userList[_state.activeUserIndex].aboutMe != null)
              dashboardTinderUserPreviewWidgetUserDescContainer(
                _state.userList[_state.activeUserIndex],
                context,
                LocalizationService.of(context).t('tinder_about_me'),
              ),
            dashboardTinderUserPreviewToolbarWidgetContainer(
              // an action toolbar
              DashboardTinderActionToolbarWidget(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    if (_state.filtersPermission!.isPromoted) {
      widget.showAccessDeniedAlert(context);

      return;
    }

    showPlatformDialog(
      context: context,
      builder: (_) => DashboardTinderFilterPopupWidget(),
    );
  }
}
