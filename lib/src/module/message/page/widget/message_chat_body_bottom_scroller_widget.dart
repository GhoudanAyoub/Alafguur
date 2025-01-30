import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../state/message_state.dart';
import '../style/message_chat_body_bottom_scroller_widget_style.dart';

class MessagesChatBodyBottomScrollerWidget extends StatelessWidget {
  final MessageState state;

  const MessagesChatBodyBottomScrollerWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => state.isContentScrollerActive
            ? messageChatBodyBottomScrollerWidgetContainer(
                context,
                () => state.contentScroll(useDelay: false),
                state.unreadMessages.length,
              )
            : Container(),
      );
}
