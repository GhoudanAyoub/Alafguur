import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:sprintf/sprintf.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/match_action_widget_mixin.dart';
import '../../base/service/localization_service.dart';
import '../../dashboard/page/widget/conversation/dashboard_conversation_widget_mixin.dart';
import '../../message/message_config.dart';
import '../service/model/guest_model.dart';
import 'state/guest_state.dart';
import 'style/guest_page_style.dart';
import 'widget/guest_nothing_found_widget.dart';
import 'widget/guest_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class GuestPage extends AbstractPage
    with MatchActionWidgetMixin, DashboardConversationWidgetMixin {
  const GuestPage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _GuestPageState createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage>
    with SingleTickerProviderStateMixin{
  late final GuestState _state;

  late final SlidableController slidableController = SlidableController(this);

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<GuestState>();

    widget.logViewList('guest-list');
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        scrollable: false,
        header: LocalizationService.of(context).t(
          'guests_page_header',
        ),
        backgroundColor: !_state.isPageLoaded
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
        body: _state.isPageLoaded ? _guestsPage() : GuestSkeletonWidget(),
        backButtonCallback: () => _markGuestsAsRead(),
      ),
    );
  }

  Widget _guestsPage() {
    // nothing found
    if (_state.guests.isEmpty) {
      return GuestNothingFoundWidget();
    }

    return guestPageWrapperContainer(
      ListView.builder(
        itemCount: _state.guests.length,
        cacheExtent: MediaQuery.of(context).size.height * 2,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            key: Key(index.toString()),
            controller: slidableController,
            direction: Axis.horizontal,
            // actionPane: SlidableScrollActionPane(),
            child: userListItemRow(
              context,
              _state.guests[index].user,
              () => _showProfilePage(_state.guests[index]),
              additionalInfo: sprintf('%s', [
                _state.guests[index].visitDate,
              ]),
              isHighlighted: !_state.guests[index].viewed!,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getMainActions(GuestModel guest) {
    if (!widget.isRtlMode(context)) {
      return [];
    }

    return _getAllActions(guest);
  }

  List<Widget> _getSecondaryActions(GuestModel guest) {
    if (widget.isRtlMode(context)) {
      return [];
    }

    return _getAllActions(guest);
  }

  List<Widget> _getAllActions(GuestModel guest) {
    return [
      // display a like button
      if (guest.user!.matchAction == null)
        guestPageLikeActionContainer(
          LocalizationService.of(context).t('like'),
          () => _likeProfile(guest),
        ),
      // display a chat button
      if (widget.isChatAllowed(guest.user))
        guestPageSendMessageActionContainer(
          LocalizationService.of(context).t('send_message'),
          () => _showChatPage(guest.user!.id),
        ),

      // remove from the guests
      guestPageRemoveActionContainer(
        LocalizationService.of(context).t('remove'),
        () => _removeProfile(guest),
      ),
    ];
  }

  void _likeProfile(GuestModel guest) {
    widget.likeUser(
      guest.user!.id!,
      guest.user!.userName,
      context,
      () => _state.likeProfile(guest),
    );
  }

  void _showChatPage(int? profileId) {
    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        MESSAGES_MAIN_URL,
        ['userId'],
        [profileId],
      ),
    );
  }

  void _showProfilePage(GuestModel guest) {
    // mark a guest as viewed
    if (!guest.viewed!) {
      _state.markGuestsAsRead(id: guest.id);
    }

    widget.redirectToProfilePage(
      context,
      guest.user!.id,
    );
  }

  void _removeProfile(GuestModel guest) {
    widget.showConfirmation(
      context,
      'delete_guest_confirmation',
      () {
        _state.deleteGuest(guest);
        widget.showMessage('profile_removed_from_guests', context);
      },
    );
  }

  void _markGuestsAsRead() {
    if (_state.getNewGuestsCount() > 0) {
      _state.markGuestsAsRead();
    }
  }
}
