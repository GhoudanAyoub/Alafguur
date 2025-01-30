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
import 'state/compatible_user_state.dart';
import 'style/compatible_user_page_style.dart';
import 'widget/compatible_user_nothing_found_widget.dart';
import 'widget/compatible_user_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class CompatibleUserPage extends AbstractPage
    with MatchActionWidgetMixin, DashboardConversationWidgetMixin {
  const CompatibleUserPage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _CompatibleUserPageState createState() => _CompatibleUserPageState();
}

class _CompatibleUserPageState extends State<CompatibleUserPage>
    with SingleTickerProviderStateMixin{
  late final CompatibleUserState _state;

  late final SlidableController slidableController = SlidableController(this);

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<CompatibleUserState>();
    _state.init();

    widget.logViewList('compatible-user-list');
  }

  @override
  void dispose() {
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        scrollable: false,
        header: LocalizationService.of(context).t(
          'compatible_users_page_header',
        ),
        backgroundColor: !_state.isPageLoaded
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
        body: _state.isPageLoaded
            ? _matchedUsersPage()
            : CompatibleUserSkeletonWidget(),
      ),
    );
  }

  Widget _matchedUsersPage() {
    // nothing found
    if (_state.matchedUsers.isEmpty) {
      return CompatibleUserNothingFoundWidget();
    }

    // matched user list
    return compatibleUserWrapperContainer(
      ListView.builder(
        itemCount: _state.matchedUsers.length,
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
              _state.matchedUsers[index].user,
              () => _showProfilePage(index),
              additionalInfo: sprintf('%s: %s%', [
                LocalizationService.of(context).t('compatibility'),
                _state.matchedUsers[index].user.compatibility,
              ]),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getMainActions(int index) {
    if (!widget.isRtlMode(context)) {
      return [];
    }

    return _getAllActions(index);
  }

  List<Widget> _getSecondaryActions(int index) {
    if (widget.isRtlMode(context)) {
      return [];
    }

    return _getAllActions(index);
  }

  List<Widget> _getAllActions(int index) {
    return [
      // display a like button
      if (_state.matchedUsers[index].user.matchAction == null)
        compatibleUserPageLikeActionContainer(
          LocalizationService.of(context).t('like'),
          () => _likeProfile(index),
        ),
      // display a chat button
      if (widget.isChatAllowed(_state.matchedUsers[index].user))
        compatibleUserPageSendMessageActionContainer(
          LocalizationService.of(context).t('send_message'),
          () => _showChatPage(_state.matchedUsers[index].user.id),
        ),
    ];
  }

  void _likeProfile(int index) {
    widget.likeUser(
      _state.matchedUsers[index].user.id!,
      _state.matchedUsers[index].user.userName,
      context,
      () => _state.likeProfile(_state.matchedUsers[index]),
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

  void _showProfilePage(int index) {
    widget.redirectToProfilePage(
      context,
      _state.matchedUsers[index].user.id,
    );
  }
}
