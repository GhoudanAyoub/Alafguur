import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/analytic_widget_mixin.dart';
import '../../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../state/dashboard_hot_list_state.dart';
import '../../style/hot_list/dashboard_hot_list_widget_style.dart';
import 'dashboard_hot_list_not_found_widget.dart';
import 'dashboard_hot_list_skeleton_widget.dart';
import 'dashboard_hot_list_user_widget.dart';

class DashboardHotListWidget extends StatefulWidget
    with
        AnalyticWidgetMixin,
        ModalWidgetMixin,
        NavigationWidgetMixin,
        PaymentPermissionWidgetMixin,
        FlushbarWidgetMixin {
  @override
  _DashboardHotListWidgetState createState() => _DashboardHotListWidgetState();
}

class _DashboardHotListWidgetState extends State<DashboardHotListWidget> {
  late final DashboardHotListState _state;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardHotListState>();
    _state.init();

    // we need to restore the scroll position every time when the page is active
    _scrollController =
        ScrollController(initialScrollOffset: _state.scrollOffset);
    _scrollController
      ..addListener(() => _state.scrollOffset = _scrollController.offset);

    widget.logViewList('hot-list');
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
            ? DashboardHotListSkeletonWidget()
            : _hotList(),
      ),
    );
  }

  Widget _hotList() {
    return Stack(
      alignment: Alignment.center,
      children: [
        dashboardHotListWidgetWrapperContainer(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // user list
              if (_state.hotList.isNotEmpty)
                DashboardHotListUserWidget(
                  state: _state,
                  scrollController: _scrollController,
                ),
              // not found
              if (_state.hotList.isEmpty) DashboardHotListNotFoundWidget(),
            ],
          ),
        ),
        // add to the list button
        if (_state.isHotListJoinAllowed())
          dashboardHotListWidgetAddToListButtonContainer(
            context,
            'hot_list_join',
            _addMeToHotList,
            _state.isRequestPending,
          ),
        // delete from the list button
        if (_state.isMeInList)
          dashboardHotListWidgetAddToListButtonContainer(
            context,
            'hot_list_remove',
            _deleteMeFromHotList,
            _state.isRequestPending,
          )
      ],
    );
  }

  /// add the current user to the hot list
  void _addMeToHotList() {
    if (_state.isRequestPending) {
      return;
    }

    if (_state.permission!.isPromoted) {
      widget.showAccessDeniedAlert(context);

      return;
    }

    // show a confirmation window
    if (_state.permission!.creditsCost < 0) {
      final message = LocalizationService.of(context).t(
        'hot_list_join_confirmation',
        searchParams: ['count'],
        replaceParams: [
          _state.permission!.creditsCost.abs().toString(),
        ],
      );

      widget.showConfirmation(
        context,
        message,
        () => _addMeToHotListRequest(),
      );

      return;
    }

    _addMeToHotListRequest();
  }

  Future<void> _addMeToHotListRequest() async {
    await _state.joinMeToHotList();

    if (_state.permission!.creditsCost != 0) {
      final String message = _state.permission!.creditsCost > 0
          ? 'increase_credits_notification'
          : 'decrease_credits_notification';

      widget.showMessage(
        message,
        context,
        translate: true,
        searchParams: ['count'],
        replaceParams: [
          _state.permission!.creditsCost.abs().toString(),
        ],
      );
    }
  }

  /// delete the current user from the hot list
  void _deleteMeFromHotList() {
    if (_state.isRequestPending) {
      return;
    }

    widget.showConfirmation(
      context,
      LocalizationService.of(context).t('hot_list_delete_confirmation'),
      () => _state.deleteMeFromHotList(),
    );
  }
}
