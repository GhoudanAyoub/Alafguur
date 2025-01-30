import 'package:flutter/material.dart';

import '../../../../base/service/localization_service.dart';
import '../../../service/model/message_model.dart';
import '../../state/message_state.dart';
import '../../style/message_chat_body_widget_style.dart';
import '../../style/message_type/message_type_wink_widget_style.dart';

class MessageTypeWinkWidget extends StatelessWidget {
  final MessageState state;
  final int index;

  const MessageTypeWinkWidget({
    Key? key,
    required this.state,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = state.sortedMessages[index];

    // a sent message
    if (message.isAuthor)
      return messageChatBodyWidgetSentMessageContainer(
        _getMessageBody(context, message, null),
        context,
      );

    // a received message
    return _getMessageBody(
      context,
      message,
      message.id == state.lastUnreadMessageId
          ? LocalizationService.of(context).t('mailbox_unread_messages')
          : null,
    );
  }

  Widget _getMessageBody(
    BuildContext context,
    MessageModel message,
    String? unreadMessageText,
  ) {
    final prevMessage = state.getPrevMessage(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // a date label
        if (message.date != null &&
            (prevMessage == null || prevMessage.date != message.date))
          messageChatBodyWidgetMessageDateContainer(
            state.sortedMessages[index].dateLabel,
          ),

        // an unread messages divider
        if (unreadMessageText != null)
          messageChatBodyWidgetUnreadMessageWrapperContainer(unreadMessageText),

        // outer body container (the whole message)
        messageTypeWinkWidgetWrapperContainer(
          [
            // an icon
            messageTypeWinkWidgetIconContainer(
              message,
            ),
            messageTypeWinkWidgetTextWrapperContainer(
              [
                // a message
                messageTypeWinkWidgetTextContainer(
                  message,
                  LocalizationService.of(context).t('mailbox_wink_sent_desc'),
                  LocalizationService.of(context)
                      .t('mailbox_wink_received_desc'),
                ),

                // a message time
                messageChatBodyWidgetMessageTimeContainer(
                  message,
                  context,
                  message.isAuthor,
                  isWink: true,
                ),
              ],
              message.isAuthor,
              context,
            ),
          ],
          context,
          message.isAuthor,
        ),
      ],
    );
  }
}
