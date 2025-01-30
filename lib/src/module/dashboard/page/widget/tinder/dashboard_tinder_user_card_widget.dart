import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:tcard/tcard.dart';

import '../../../../base/page/widget/distance_widget_mixin.dart';
import '../../../../base/page/widget/match_action_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/page/widget/rtl_widget_mixin.dart';
import '../../../../base/service/model/user_match_action_model.dart';
import '../../../../base/service/model/user_model.dart';
import '../../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../state/dashboard_tinder_state.dart';
import '../../style/tinder/dashboard_tinder_user_card_widget_style.dart';
import 'dashboard_tinder_action_toolbar_widget.dart';
import 'dashboard_tinder_filter_popup_widget.dart';
import 'dashboard_tinder_user_preview_widget.dart';

class DashboardTinderUserCardWidget extends StatefulWidget
    with
        RtlWidgetMixin,
        NavigationWidgetMixin,
        DistanceWidgetMixin,
        ModalWidgetMixin,
        PaymentPermissionWidgetMixin,
        MatchActionWidgetMixin {
  @override
  _DashboardTinderUserCardWidgetState createState() =>
      _DashboardTinderUserCardWidgetState();
}

class _DashboardTinderUserCardWidgetState
    extends State<DashboardTinderUserCardWidget> {
  TCardController _controller = TCardController();
  late DashboardTinderState _state;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardTinderState>();

    _state.setLikeClickedCallback(_likeClickedCallback());
    _state.setSkipClickedCallback(_skipClickedCallback());
    _state.setDislikeClickedCallback(_dislikeClickedCallback());
    _state.setBackClickedCallback(_backClickedCallback());
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          // actions toolbar
          dashboardTinderUserCardWidgetToolbarContainer(
            DashboardTinderActionToolbarWidget(),
          ),

          // user cards
          dashboardTinderUserCardWidgetCardsContainer(
            context,
            TCard(
              dragCallback: _dragCardCallback(),
              dragStopCallback: _dragStopCardCallback(),
              throwingDistance: 7.0,
              controller: _controller,
              cards: _getCards(context),
              onForward: (int index, SwipInfo info) {
                // dislike handler
                if (info.direction == SwipDirection.Left) {
                  widget.isRtlMode(context)
                      ? _likeProfile(index - 1)
                      : _dislikeProfile(index - 1);
                  return;
                }

                // like handler
                if (info.direction == SwipDirection.Right) {
                  widget.isRtlMode(context)
                      ? _dislikeProfile(index - 1)
                      : _likeProfile(index - 1);

                  return;
                }

                _skipProfile();
              },
            ),
          ),

          // preview user mode
          if (_state.isPreviewMode)
            dashboardTinderUserCardWidgetPreviewContainer(
              DashboardTinderUserPreviewWidget(),
            ),
        ],
      ),
    );
  }

  List<Widget> _getCards(BuildContext context) {
    final List<Widget> cards = [];

    _state.userList.asMap().forEach(
          (index, user) => cards.add(
            Observer(
              builder: (BuildContext context) =>
                  dashboardTinderUserCardWidgetCardContainer(
                user,
                () => _viewProfilePage(user),
                context,
                distance: user.distance != null
                    ? widget.getDistance(user, context)
                    : null,
                isCardMovingToLeft: _state.isCardMovingToLeft,
                isCardMovingToRight: _state.isCardMovingToRight,
                cardIndex: index,
                activeCardIndex: _state.activeUserIndex,
                isPreviewMode: _state.isPreviewMode,
                isFiltersAllowed: _state.isFiltersAllowed,
                userCardClickCallbackSettings: () => _showFilters(),
              ),
            ),
          ),
        );

    return cards;
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

  void _viewProfilePage(UserModel user) {
    widget.redirectToProfilePage(
      context,
      user.id,
    );
  }

  void _likeProfile(int index) {
    widget.likeUser(
      _state.userList[index].id!,
      _state.userList[index].userName,
      context,
      () => _state.increaseUserIndex(
        matchAction: MatchActionTypeEnum.like,
      ),
      cancelCallback: () => _controller.back(),
    );
  }

  void _skipProfile() {
    _state.increaseUserIndex();
  }

  void _dislikeProfile(int index) {
    widget.dislikeUser(
      _state.userList[index].id!,
      _state.userList[index].userName!,
      context,
      () => _state.increaseUserIndex(
        matchAction: MatchActionTypeEnum.dislike,
      ),
      cancelCallback: () => _controller.back(),
    );
  }

  DragCallback _dragCardCallback() {
    return (bool isLeft, bool isRight) {
      _state.isCardMovingToLeft = isLeft;
      _state.isCardMovingToRight = isRight;
    };
  }

  DragStopCallback _dragStopCardCallback() {
    return (bool isLeft, bool isRight) {
      _state.isCardMovingToLeft = false;
      _state.isCardMovingToRight = false;
    };
  }

  OnLikeClickedCallback _likeClickedCallback() {
    return () {
      final direction =
          widget.isRtlMode(context) ? SwipDirection.Left : SwipDirection.Right;

      _controller.forward(direction: direction);
    };
  }

  OnSkipClickedCallback _skipClickedCallback() {
    return () {
      _controller.forward(direction: SwipDirection.None);
    };
  }

  OnDislikeClickedCallback _dislikeClickedCallback() {
    return () {
      final direction =
          widget.isRtlMode(context) ? SwipDirection.Right : SwipDirection.Left;

      _controller.forward(direction: direction);
    };
  }

  OnBackClickedCallback _backClickedCallback() {
    return () {
      _controller.back();
      _state.decreaseUserIndex();
    };
  }
}
