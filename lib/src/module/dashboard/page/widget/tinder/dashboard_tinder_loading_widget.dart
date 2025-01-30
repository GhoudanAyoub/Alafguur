import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../state/dashboard_tinder_state.dart';
import '../../style/tinder/dashboard_tinder_loading_widget_style.dart';
import 'dashboard_tinder_filter_popup_widget.dart';

class DashboardTinderLoadingWidget extends StatefulWidget
    with NavigationWidgetMixin, ModalWidgetMixin, PaymentPermissionWidgetMixin {
  @override
  _DashboardTinderLoadingState createState() => _DashboardTinderLoadingState();
}

class _DashboardTinderLoadingState extends State<DashboardTinderLoadingWidget>
    with TickerProviderStateMixin {
  late final DashboardTinderState _state;
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<DashboardTinderState>();

    _radarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // an avatar
              if (_state.me != null)
                dashboardTinderLoadingWidgetRadarAnimationAvatarContainer(
                  _radarController,
                  _state.me!.avatar,
                ),
            ],
          ),
          Positioned(
            bottom: 16,
            child: Column(
              children: [
                // no users
                if (_state.isNoUsersDescriptionVisible) ...[
                  dashboardTinderLoadingWidgetNoUsersContainer(
                    LocalizationService.of(context).t(
                      'tinder_nomatches_left_header',
                    ),
                    LocalizationService.of(context).t(
                      'tinder_nomatches_left_desc',
                    ),
                  ),

                  // filters
                  if (_state.isFiltersAllowed)
                    dashboardTinderLoadingWidgetFiltersContainer(
                      LocalizationService.of(context).t(
                        'tinder_nomatches_change_filter',
                      ),
                      () => _showFilters(context),
                    ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
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
