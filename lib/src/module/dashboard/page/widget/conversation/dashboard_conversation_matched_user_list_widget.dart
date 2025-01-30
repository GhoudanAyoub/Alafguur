import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../base/service/model/user_model.dart';
import '../../../../message/message_config.dart';
import '../../../service/model/dashboard_matched_user_model.dart';
import '../../state/dashboard_conversation_state.dart';
import '../../style/conversation/dashboard_conversation_matched_user_widget_style.dart';
import '../../style/conversation/dashboard_conversation_widget_style.dart';

class DashboardConversationMatchedUserListWidget extends StatefulWidget
    with NavigationWidgetMixin {
  final List<DashboardMatchedUserModel> matchedUsers;

  const DashboardConversationMatchedUserListWidget({
    Key? key,
    required this.matchedUsers,
  }) : super(key: key);

  @override
  _DashboardConversationMatchedUserListWidgetState createState() =>
      _DashboardConversationMatchedUserListWidgetState();
}

class _DashboardConversationMatchedUserListWidgetState
    extends State<DashboardConversationMatchedUserListWidget> {
  late final DashboardConversationState _state;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardConversationState>();
    _state.init();

    // we need to restore the scroll position every time when the page is active
    _scrollController =
        ScrollController(initialScrollOffset: _state.matchedUsersScrollOffset);
    _scrollController
      ..addListener(
        () => _state.matchedUsersScrollOffset = _scrollController.offset,
      );
  }

  @override
  void dispose() {
    super.dispose();
    _state.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // a header
        dashboardConversationWidgetHeaderContainer(
          LocalizationService.of(context).t('new_matches'),
        ),

        // a matched user list
        dashboardConversationWidgetMatchedUsersWrapperContainer(
          ListView.builder(
            cacheExtent: MediaQuery.of(context).size.width * 2,
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.matchedUsers.length,
            itemBuilder: (context, index) {
              return dashboardConversationWidgetMatchedUserItemContainer(
                widget.matchedUsers[index],
                () => _showChat(widget.matchedUsers[index].user),
                context,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showChat(UserModel user) {
    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        MESSAGES_MAIN_URL,
        ['userId'],
        [
          user.id,
        ],
      ),
    );
  }
}
