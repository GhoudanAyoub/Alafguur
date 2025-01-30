import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../base/service/model/user_model.dart';
import '../../../../message/message_config.dart';
import '../../../service/model/dashboard_conversation_model.dart';
import '../../state/dashboard_conversation_state.dart';
import '../../style/conversation/dashboard_conversation_list_widget_style.dart';
import '../../style/conversation/dashboard_conversation_widget_style.dart';
import 'conversation_action_widget_mixin.dart';

class DashboardConversationListWidget extends StatefulWidget
    with
        NavigationWidgetMixin,
        ActionSheetWidgetMixin,
        FlushbarWidgetMixin,
        ModalWidgetMixin,
        ConversationActionWidgetMixin {
  final List<DashboardConversationModel> conversations;

  const DashboardConversationListWidget({
    Key? key,
    required this.conversations,
  }) : super(key: key);

  @override
  _DashboardConversationListWidgetState createState() =>
      _DashboardConversationListWidgetState();
}

class _DashboardConversationListWidgetState
    extends State<DashboardConversationListWidget> {
  late final DashboardConversationState _state;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardConversationState>();
    _state.init();

    // we need to restore the scroll position every time when the page is active
    _scrollController =
        ScrollController(initialScrollOffset: _state.conversationsScrollOffset);
    _scrollController
      ..addListener(
        () => _state.conversationsScrollOffset = _scrollController.offset,
      );
  }

  @override
  void dispose() {
    _state.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: dashboardConversationWidgetConversationsWrapperContainer(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // a header
            dashboardConversationWidgetHeaderContainer(
              LocalizationService.of(context).t('new_messages'),
              paddingHorizontal: 0,
            ),
            // a conversation list
            Expanded(
              child: ListView.builder(
                cacheExtent: MediaQuery.of(context).size.height * 2,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: widget.conversations.length,
                itemBuilder: (context, index) {
                  return dashboardConversationWidgetConversationsItemContainer(
                    widget.conversations[index],
                    () => _showChat(widget.conversations[index].user),
                    () => widget.showConversationActions(
                      context,
                      widget.conversations[index],
                      _state,
                    ),
                    context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
