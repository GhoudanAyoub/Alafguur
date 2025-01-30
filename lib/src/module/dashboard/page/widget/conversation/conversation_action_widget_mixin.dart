import 'package:flutter/widgets.dart';

import '../../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/service/model/action_sheet_model.dart';
import '../../../service/model/dashboard_conversation_model.dart';
import '../../state/dashboard_conversation_state.dart';

mixin ConversationActionWidgetMixin
    on ActionSheetWidgetMixin, FlushbarWidgetMixin, ModalWidgetMixin {
  void showConversationActions(
    BuildContext context,
    DashboardConversationModel conversation,
    DashboardConversationState state,
  ) {
    showActionSheet(context, [
      // block user
      if (!conversation.user.isBlocked!)
        ActionSheetModel(
          label: 'block_profile',
          callback: () => _blockProfile(
            context,
            state,
            conversation,
          ),
        ),
      // unblock user
      if (conversation.user.isBlocked!)
        ActionSheetModel(
          label: 'unblock_profile',
          callback: () {
            state.unblockProfile(conversation);
            showMessage('profile_unblocked', context);
          },
        ),
      // delete conversation
      ActionSheetModel(
        label: 'delete_conversation',
        callback: () => _deleteConversation(
          context,
          state,
          conversation,
        ),
      ),
      // mark the  conversation as read
      if (conversation.isNew)
        ActionSheetModel(
          label: 'mark_read_conversation',
          callback: () {
            state.markConversationAsRead(conversation);
            showMessage('conversation_has_been_marked_as_read', context);
          },
        ),
      // mark the conversation as new
      if (!conversation.isNew)
        ActionSheetModel(
          label: 'mark_unread_conversation',
          callback: () {
            state.markConversationAsNew(conversation);
            showMessage('conversation_has_been_marked_as_unread', context);
          },
        ),
    ]);
  }

  void _blockProfile(
    BuildContext context,
    DashboardConversationState state,
    DashboardConversationModel conversation,
  ) {
    showConfirmation(
      context,
      'block_profile_confirmation',
      () {
        state.blockProfile(conversation);
        showMessage('profile_blocked', context);
      },
      noLabel: 'no',
      yesLabel: 'yes',
    );
  }

  void _deleteConversation(
    BuildContext context,
    DashboardConversationState state,
    DashboardConversationModel conversation,
  ) {
    showConfirmation(
      context,
      'delete_conversation_confirmation',
      () {
        state.deleteConversation(conversation);
        showMessage('conversation_has_been_deleted', context);
      },
      noLabel: 'no',
      yesLabel: 'yes',
    );
  }
}
