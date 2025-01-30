import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../state/message_state.dart';
import '../style/message_chat_body_widget_style.dart';
import 'message_chat_body_empty_widget.dart';
import 'message_type/message_type_oembed_widget.dart';
import 'message_type/message_type_plain_widget.dart';
import 'message_type/message_type_wink_widget.dart';

class MessagesChatBodyWidget extends StatefulWidget {
  final MessageState state;

  const MessagesChatBodyWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  _MessagesChatBodyWidgetState createState() => _MessagesChatBodyWidgetState();
}

class _MessagesChatBodyWidgetState extends State<MessagesChatBodyWidget> {
  ItemScrollController? _itemScrollController;
  ItemPositionsListener? _itemPositionsListener;

  int _scrollDelayMilliseconds = 400;
  Timer? _scrollTimerHandler;

  @override
  void initState() {
    super.initState();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener!.itemPositions.addListener(_onScrollMessages);
    widget.state.setNewMessagesCallback(_onNewMessages());
    widget.state.setContentScrollCallback(_onContentScroll());
  }

  @override
  void dispose() {
    _itemPositionsListener!.itemPositions.removeListener(_onScrollMessages);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => widget.state.sortedMessages.isEmpty
            ? MessagesChatBodyEmptyWidget(state: widget.state)
            : _messageList(),
      );

  /// generate a message list
  Widget _messageList() {
    return messageChatBodyWidgetWrapperContainer(
      <Widget>[
        // a history loading
        if (widget.state.isHistoryLoading)
          messageChatBodyWidgetHistoryLoadingContainer(),

        // messages
        Expanded(
          child: ScrollablePositionedList.builder(
            physics: ClampingScrollPhysics(),
            initialScrollIndex: widget.state.sortedMessages.length - 1,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            itemCount: widget.state.sortedMessages.length,
            itemBuilder: (BuildContext context, int index) {
              // return a plain message
              if (widget.state
                  .isPlainMessage(widget.state.sortedMessages[index])) {
                return MessageTypePlainWidget(
                  state: widget.state,
                  index: index,
                );
              }

              // return a wink message
              if (widget.state
                  .isWinkMessage(widget.state.sortedMessages[index])) {
                return MessageTypeWinkWidget(
                  state: widget.state,
                  index: index,
                );
              }

              // return an oembed message
              return MessageTypeOembedWidget(
                state: widget.state,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  OnNewMessagesCallback _onNewMessages() {
    return () {
      // scroll to the bottom if we are not reading messages far from the bottom
      if (_isContentScrolledToBottom()) {
        _scrollToBottom(true);
      }
    };
  }

  OnContentScrollCallback _onContentScroll() {
    return (bool useDelay) => _scrollToBottom(useDelay);
  }

  Future<void> _onScrollMessages() async {
    final bool isContentScrollerActive = !_isContentScrolledToBottom();

    // define if we need to show the content scroller
    if (isContentScrollerActive != widget.state.isContentScrollerActive) {
      widget.state.isContentScrollerActive = isContentScrollerActive;
    }

    // mark all unread messages as read
    if (!widget.state.isContentScrollerActive) {
      widget.state.markMessagesAsRead();
    }

    // enable the history loader
    if (_lastActiveMessageIndex != 0) {
      widget.state.isHistoryLoadAllowed = true;
    }

    // load the history if we scrolled to the top
    if (_lastActiveMessageIndex == 0 && widget.state.isHistoryLoadAllowed) {
      await widget.state.loadHistory();
      widget.state.isHistoryLoadAllowed = false;
    }
  }

  // scroll messages to the bottom position
  void _scrollToBottom(bool useDelay) {
    // cancel previous scrolling
    if (_scrollTimerHandler != null) {
      _scrollTimerHandler!.cancel();
      _scrollTimerHandler = null;
    }

    if (_itemScrollController!.isAttached) {
      if (useDelay) {
        _scrollTimerHandler = Timer(
          Duration(milliseconds: _scrollDelayMilliseconds),
          () => _itemScrollController!.scrollTo(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            index: widget.state.lastDeliveredMessageIndex(),
            alignment: 0,
          ),
        );

        return;
      }

      _itemScrollController!.scrollTo(
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        index: widget.state.lastDeliveredMessageIndex(),
        alignment: 0,
      );
    }
  }

  // check how we far from the bottom
  bool _isContentScrolledToBottom() {
    if (widget.state.sortedMessages.length -
            widget.state.scrollMessagesThreshold >=
        _lastActiveMessageIndex) {
      return false;
    }

    return true;
  }

  int get _lastActiveMessageIndex {
    try {
      return _itemPositionsListener?.itemPositions.value.last.index ?? 0;
    } catch (error) {
      return 0;
    }
  }
}
