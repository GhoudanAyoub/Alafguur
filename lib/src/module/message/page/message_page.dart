import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/service/model/action_sheet_model.dart';
import '../../payment/page/widget/payment_permission_widget_mixin.dart';
import 'state/message_state.dart';
import 'style/message_page_style.dart';
import 'widget/message_chat_body_bottom_scroller_widget.dart';
import 'widget/message_chat_body_widget.dart';
import 'widget/message_chat_footer_widget.dart';
import 'widget/message_chat_skeleton_widget.dart';
import 'widget/message_chat_widget_mixin.dart';

final serviceLocator = GetIt.instance;

class MessagePage extends AbstractPage
    with MessageChatWidgetMixin, PaymentPermissionWidgetMixin {
  const MessagePage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final MessageState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<MessageState>();
    _state.init(int.parse(widget.routeParams!['userId'][0]));

    if (widget.widgetParams!['isPrevPageProfile'] != null) {
      _state.isPrevPageProfile = true;
    }
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
        // make it scrollable only when the page is loading
        scrollable: !_state.isPageLoaded,
        header: _state.isPageLoaded ? _state.profile!.userName : '',
        headerClickCallback: _state.isPageLoaded
            ? () => widget.showProfilePage(
                  context,
                  _state,
                )
            : null,
        headerActions: _state.isPageLoaded
            ? [
                messagePageMessagesHeaderIconContainer(
                  () => _showConversationActions(context),
                  context,
                ),
              ]
            : null,
        backgroundColor: !_state.isPageLoaded
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
        body: _state.isPageLoaded ? _chatPage() : MessageChatSkeletonWidget(),
        backButtonCallback: () {
          _state.markUserAsViewed();
          _state.markConversationAsRead();
        },
      ),
    );
  }

  Widget _chatPage() {
    return Stack(
      children: [
        // a chat body
        messagePageMessagesBodyAreaContainer(
          MessagesChatBodyWidget(state: _state),
          _state.isSendMessageAreaAllowed(),
          _state.isSendMessageAreaPromoted(),
        ),

        // a bottom scroller
        MessagesChatBodyBottomScrollerWidget(state: _state),

        // a chat footer
        if (_state.isSendMessageAreaAllowed() ||
            _state.isSendMessageAreaPromoted())
          messagePageMessagesSendingAreaContainer(
            context,
            MessagesChatFooterWidget(state: _state),
            () => _showAccessDenied(context),
          ),
      ],
    );
  }

  void _showAccessDenied(BuildContext context) {
    if (_state.isSendMessageAreaPromoted()) {
      widget.showAccessDeniedAlert(context);
    }
  }

  /// show all the conversation's actions
  void _showConversationActions(BuildContext context) {
    widget.showActionSheet(
      context,
      [
        // block user
        if (!_state.profile!.isBlocked!)
          ActionSheetModel(
            label: 'block_profile',
            callback: () => _blockProfile(context),
          ),
        // unblock user
        if (_state.profile!.isBlocked!)
          ActionSheetModel(
            label: 'unblock_profile',
            callback: () {
              _state.unblockProfile();
              widget.showMessage('profile_unblocked', context);
            },
          ),
        // delete conversation
        if (_state.getConversation() != null) ...[
          ActionSheetModel(
            label: 'delete_conversation',
            callback: () => _deleteConversation(context),
          ),
          // mark the conversation as unread
          ActionSheetModel(
            label: 'mark_unread_conversation',
            callback: () {
              _state.markConversationAsNew();
              Navigator.pop(context);
              widget.showMessage(
                'conversation_has_been_marked_as_unread',
                context,
              );
            },
          ),
        ],
      ],
    );
  }

  void _deleteConversation(
    BuildContext context,
  ) {
    widget.showConfirmation(
      context,
      'delete_conversation_confirmation',
      () {
        _state.deleteConversation();
        Navigator.pop(context);
        widget.showMessage('conversation_has_been_deleted', context);
      },
      noLabel: 'no',
      yesLabel: 'yes',
    );
  }

  void _blockProfile(
    BuildContext context,
  ) {
    widget.showConfirmation(
      context,
      'block_profile_confirmation',
      () {
        _state.blockProfile();
        widget.showMessage('profile_blocked', context);
      },
      noLabel: 'no',
      yesLabel: 'yes',
    );
  }
}
