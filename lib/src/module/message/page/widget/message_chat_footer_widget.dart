import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/widget/action_sheet_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/page/widget/keyboard_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/page/widget/photo_uploader_chooser_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../../payment/page/widget/payment_permission_widget_mixin.dart';
import '../state/message_state.dart';
import '../style/message_chat_footer_widget_style.dart';

final serviceLocator = GetIt.instance;

class MessagesChatFooterWidget extends StatefulWidget
    with
        FlushbarWidgetMixin,
        ModalWidgetMixin,
        NavigationWidgetMixin,
        PaymentPermissionWidgetMixin,
        ActionSheetWidgetMixin,
        KeyboardWidgetMixin,
        PhotoUploaderChooserWidgetMixin {
  final MessageState state;

  const MessagesChatFooterWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  _MessagesChatFooterWidgetState createState() =>
      _MessagesChatFooterWidgetState();
}

class _MessagesChatFooterWidgetState extends State<MessagesChatFooterWidget> {
  FormBuilderWidget? _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _formBuilderWidget!.registerFormElements(
      widget.state.getFormElements(),
    );
    _formBuilderWidget!.registerFormOnChangedCallback(
      _onChangedValueCallback(),
    );
    _formBuilderWidget!.registerFormOnFocusedCallback(
      _onFocusedCallback(),
    );

    // apply a custom form renderer
    _formBuilderWidget!.registerFormRenderer(
      messageChatFooterWidgetFormRenderer(),
    );

    // apply a custom theme for the form
    _formBuilderWidget!.registerFormTheme(
      messageChatFooterWidgetFormTheme(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => messageChatFooterWidgetWrapContainer(
        <Widget>[
          // an attachment icon
          messageChatFooterWidgetAttachmentContainer(
            () => _sendImageMessage(context),
            widget.state.isSendMessageAreaPromoted(),
          ),

          // a textarea
          if (!widget.state.isSendMessageAreaPromoted())
            Expanded(
              child:
                  messageChatFooterWidgetTextareaContainer(_formBuilderWidget),
            ),

          // a promoted message
          if (widget.state.isSendMessageAreaPromoted())
            Expanded(
              child: messageChatFooterWidgetTextareaPromotedContainer(
                LocalizationService.of(context).t(
                  'mailbox_send_message_promotion_desc',
                ),
              ),
            ),

          // a send button
          messageChatFooterWidgetSendMessageButtonContainer(
            LocalizationService.of(context).t('send'),
            () => _sendTextMessage(context),
            widget.state.isMessageValid,
            widget.state.isSendMessageAreaPromoted(),
          ),
        ],
        widget.state.isSendMessageAreaPromoted(),
      ),
    );
  }

  Future<void> _sendImageMessage(BuildContext context) async {
    // check permissions
    if (widget.state.isSendMessageAreaPromoted() ||
        !widget.state.isSendMessageAreaAllowed()) {
      widget.showAccessDeniedAlert(context);

      return;
    }

    widget.displayPhotoUploadChooser(
      context,
      () => _uploadImageMessage(context, true),
      () => _uploadImageMessage(context, false),
    );
  }

  Future<void> _uploadImageMessage(
    BuildContext context,
    bool useCamera,
  ) async {
    // wait for the file picker to return
    final image = await widget.state.chooseImage(useCamera);

    if (image == null) {
      widget.showMessage('error_choose_correct_photo', context);

      return;
    }

    widget.state.sendImageMessage(image);
  }

  void _sendTextMessage(BuildContext context) {
    // check permissions
    if (widget.state.isSendMessageAreaPromoted() ||
        !widget.state.isSendMessageAreaAllowed()) {
      widget.showAccessDeniedAlert(context);

      return;
    }

    widget.state.isMessageValid = false;
    widget.state.sendMessage(_formBuilderWidget!['message']!.value);
    _formBuilderWidget!.reset();
  }

  OnChangedValueCallback _onChangedValueCallback() {
    return (String key, dynamic value) async {
      widget.state.isMessageValid = await _formBuilderWidget!.isFormValid();
    };
  }

  OnFocusedCallback _onFocusedCallback() {
    return (String key, bool isFocused) {
      if (isFocused && !widget.state.isContentScrollerActive) {
        widget.state.contentScroll();
      }
    };
  }
}
