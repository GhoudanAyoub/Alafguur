import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/analytic_widget_mixin.dart';
import '../../state/dashboard_conversation_state.dart';
import '../../style/conversation/dashboard_conversation_widget_style.dart';
import 'dashboard_conversation_all_empty_widget.dart';
import 'dashboard_conversation_list_widget.dart';
import 'dashboard_conversation_matched_user_list_widget.dart';
import 'dashboard_conversation_list_empty_widget.dart';
import 'dashboard_conversation_search_empty_widget.dart';
import 'dashboard_conversation_search_filter_widget.dart';
import 'dashboard_conversation_skeleton_widget.dart';

class DashboardConversationWidget extends StatefulWidget
    with AnalyticWidgetMixin {
  @override
  _DashboardConversationWidgetState createState() =>
      _DashboardConversationWidgetState();
}

class _DashboardConversationWidgetState
    extends State<DashboardConversationWidget> {
  late final DashboardConversationState _state;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardConversationState>();

    widget.logViewList('conversation-list');
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => Material(
        color: transparentColor(),
        child: !_state.isPageLoaded
            ? DashboardConversationSkeletonWidget()
            : _state.isAllEmpty
                ? DashboardConversationAllEmptyWidget()
                : _conversationList(),
      ),
    );
  }

  Widget _conversationList() {
    final matchedUsers = _state.getMatchedUsers()!;
    final conversations = _state.getConversations()!;

    return dashboardConversationWidgetWrapperContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // search filters
          DashboardConversationSearchFilterWidget(),

          // search results are empty
          if (matchedUsers.isEmpty && conversations.isEmpty)
            DashboardConversationSearchEmptyWidget(),

          // matched users
          if (matchedUsers.isNotEmpty)
            DashboardConversationMatchedUserListWidget(
              matchedUsers: matchedUsers,
            ),

          // conversations
          if (conversations.isNotEmpty)
            DashboardConversationListWidget(
              conversations: conversations,
            ),

          // conversations are empty initially
          if (matchedUsers.isNotEmpty &&
              conversations.isEmpty &&
              _state.userNameFilter == null)
            DashboardConversationListEmptyWidget(),
        ],
      ),
    );
  }
}
