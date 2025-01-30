import 'package:flutter/material.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../state/message_state.dart';
import '../style/message_chat_body_empty_widget_style.dart';
import 'message_chat_widget_mixin.dart';

class MessagesChatBodyEmptyWidget extends StatelessWidget
    with NavigationWidgetMixin, MessageChatWidgetMixin {
  final MessageState state;

  const MessagesChatBodyEmptyWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // an avatar
        messageChatBodyEmptyWidgetAvatarContainer(
          state.profile!.avatar,
          () => showProfilePage(context, state),
        ),
        // a user name
        blankBasedPageTitleContainer(
          state.profile!.userName,
          clickCallback: () => showProfilePage(context, state),
        ),
        // a description
        blankBasedPageDescrContainer(
          LocalizationService.of(context).t('mailbox_start_conversation_desc'),
        ),
      ],
    );
  }
}
