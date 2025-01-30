import 'package:flutter/material.dart';

import '../../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/page/widget/preview_photo_widget_mixin.dart';
import '../../../../base/page/widget/url_launcher_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../base/service/model/action_sheet_model.dart';
import '../../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../../../service/model/message_model.dart';
import '../../state/message_state.dart';
import '../../style/message_chat_body_widget_style.dart';
import '../../style/message_type/message_type_plain_widget_style.dart';

class MessageTypePlainWidget extends StatelessWidget
    with
        ActionSheetWidgetMixin,
        PreviewPhotoWidgetMixin,
        ModalWidgetMixin,
        UrlLauncherWidgetMixin,
        NavigationWidgetMixin,
        PaymentPermissionWidgetMixin {
  final MessageState state;
  final int index;

  const MessageTypePlainWidget({
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
        _getMessageBody(context, message),
        context,
        error: message.error,
        errorClickCallback: () => _showMessageActions(
          context,
          message,
        ),
      );

    // a received message
    return _getMessageBody(
      context,
      message,
      unreadMessageText: message.id == state.lastUnreadMessageId
          ? LocalizationService.of(context).t('mailbox_unread_messages')
          : null,
    );
  }

  Widget _getMessageBody(
    BuildContext context,
    MessageModel message, {
    String? unreadMessageText,
  }) {
    final prevMessage = state.getPrevMessage(index);

    return Column(
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
        messageChatBodyWidgetBubbleWrapperContainer(
          [
            // inner body contains (everything except date)
            messageChatBodyWidgetMessageWrapperContainer(
              [
                // a loading bar
                if (message.isLoading)
                  messageChatBodyWidgetMessageLoadingContainer(),

                // a message
                if (state.isMessageReadingAllowed(message) &&
                    (message.text != null || message.attachments.isNotEmpty))
                  messageTypePlainWidgetContainer(
                    message,
                    _openLink(context),
                    _showImage(context),
                    _showDocument(context),
                    message.isAuthor,
                    context,
                  ),

                // reading is allowed by credits
                if (state.isMessageReadingAllowedByCredits(message))
                  messageChatBodyWidgetMessageReadingPromotedContainer(
                    LocalizationService.of(context).t('read_mailbox_message'),
                    () => state.loadMessage(message),
                    message.isAuthor,
                  ),

                // reading is promoted
                if (state.isMessageReadingPromoted(message))
                  messageChatBodyWidgetMessageReadingPromotedContainer(
                    LocalizationService.of(context)
                        .t('view_mailbox_message_upgrade'),
                    () => showAccessDeniedAlert(context),
                    message.isAuthor,
                  ),

                // reading is fully denied
                if (state.isMessageReadingDenied(message))
                  messageChatBodyWidgetMessageReadingDeniedContainer(
                    LocalizationService.of(context)
                        .t('view_mailbox_message_denied'),
                    message.isAuthor,
                  ),
              ],
            ),

            // a message time
            messageChatBodyWidgetMessageTimeContainer(
              message,
              context,
              message.isAuthor,
            ),
          ],
          message.isAuthor,
          context,
        ),
      ],
    );
  }

  LinkClickCallback _openLink(BuildContext context) {
    return (String link) {
      launchUrl(context, link);
    };
  }

  AttachmentClickCallback _showImage(BuildContext context) {
    return (String url) {
      final Map photoList = state.getPhotos(url);

      showPhotoList(
        context,
        photoList['photos'],
        startIndex: photoList['index'],
      );
    };
  }

  AttachmentClickCallback _showDocument(BuildContext context) {
    return (String url) {
      launchUrl(context, url);
    };
  }

  /// show messages actions (delete, etc)
  void _showMessageActions(
    BuildContext context,
    MessageModel message,
  ) {
    showActionSheet(
      context,
      [
        ActionSheetModel(
          label: 'delete_message',
          callback: () => _deleteMessage(
            context,
            message.id,
          ),
        ),
        ActionSheetModel(
          label: 'resend_message',
          callback: () => state.resendMessage(message),
        ),
      ],
      title: message.error,
    );
  }

  void _deleteMessage(
    BuildContext context,
    dynamic id,
  ) {
    showConfirmation(context, 'delete_message_confirmation', () {
      state.deleteMessage(id);
    });
  }
}
