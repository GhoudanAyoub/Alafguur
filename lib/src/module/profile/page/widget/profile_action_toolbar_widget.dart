import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/match_action_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../dashboard/page/widget/conversation/dashboard_conversation_widget_mixin.dart';
import '../../../message/message_config.dart';
import '../state/profile_state.dart';
import '../style/profile_action_toolbar_widget_style.dart';

final serviceLocator = GetIt.instance;

class ProfileActionToolbarWidget extends StatefulWidget
    with
        DashboardConversationWidgetMixin,
        NavigationWidgetMixin,
        ModalWidgetMixin,
        MatchActionWidgetMixin,
        FlushbarWidgetMixin {
  final ProfileState state;
  final bool isPrevPageMessages;

  const ProfileActionToolbarWidget({
    Key? key,
    required this.state,
    required this.isPrevPageMessages,
  }) : super(key: key);

  @override
  _ProfileActionToolbarWidgetState createState() =>
      _ProfileActionToolbarWidgetState();
}

class _ProfileActionToolbarWidgetState extends State<ProfileActionToolbarWidget>
    with TickerProviderStateMixin {
  late AnimationController _dislikeController;
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();

    // init animation controllers
    _dislikeController = AnimationController(
      vsync: this,
      value: widget.state.actualDislikeIconBound,
      lowerBound: widget.state.dislikeIconLowerBound,
      upperBound: widget.state.dislikeIconUpperBound,
      duration: Duration(milliseconds: widget.state.animationDuration),
    );
    _dislikeController.addListener(
      () => widget.state.actualDislikeIconBound = _dislikeController.value,
    );

    _likeController = AnimationController(
      vsync: this,
      value: widget.state.actualLikeIconBound,
      lowerBound: widget.state.likeIconLowerBound,
      upperBound: widget.state.likeIconUpperBound,
      duration: Duration(milliseconds: widget.state.animationDuration),
    );

    _likeController.addListener(
      () => widget.state.actualLikeIconBound = _likeController.value,
    );
  }

  @override
  void dispose() {
    _dislikeController.dispose();
    _likeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => profileActionToolbarWidgetWrapperContainer(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // a bookmark button
            if (widget.state.isBookmarksLoaded &&
                widget.state.profile!.bookmark == null)
              profileActionToolbarWidgetBookmarkIconContainer(
                () => _bookmarkProfile(context),
              ),
            // an unbookmark button
            if (widget.state.isBookmarksLoaded &&
                widget.state.profile!.bookmark != null)
              profileActionToolbarWidgetUnbookmarkIconContainer(
                () => _unbookmarkProfile(context),
              ),
            // a dislike button
            profileActionToolbarWidgetDislikeIconContainer(
              widget.state.actualDislikeIconBound,
              widget.state.actualDislikeIconBound ==
                  widget.state.dislikeIconLowerBound,
              () => _dislike(context),
            ),
            // a like button
            profileActionToolbarWidgetLikeIconContainer(
              widget.state.actualLikeIconBound,
              false,
              () => _like(context),
            ),
            // a chat button
            if (widget.isChatAllowed(widget.state.profile))
              profileActionToolbarWidgetMessageIconContainer(
                () => _showChatPage(),
              ),
          ],
        ),
      ),
    );
  }

  /// show a chat window
  void _showChatPage() {
    // don't open the messages page twice it takes a lot of resources
    if (widget.isPrevPageMessages) {
      Navigator.pop(context);

      return;
    }

    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        MESSAGES_MAIN_URL,
        ['userId'],
        [
          widget.state.profile!.id,
        ],
      ),
      arguments: {
        'isPrevPageProfile': true,
      },
    );
  }

  /// bookmark profile
  void _bookmarkProfile(BuildContext context) {
    widget.showMessage('profile_added_to_bookmarks', context);
    widget.state.bookmarkProfile();
  }

  /// unbookmark profile
  void _unbookmarkProfile(BuildContext context) {
    widget.showMessage('profile_removed_from_bookmarks', context);
    widget.state.unbookmarkProfile();
  }

  void _dislike(BuildContext context) {
    if (widget.state.isDislikeAllowed) {
      widget.dislikeUser(
        widget.state.profile!.id!,
        widget.state.profile!.userName!,
        context,
        () {
          // dislike the profile and close the page
          widget.state.dislikeProfile();
          Navigator.pop(context);
        },
      );
    }
  }

  void _like(BuildContext context) {
    // start the animation
    if (!_likeController.isCompleted) {
      widget.likeUser(
        widget.state.profile!.id!,
        widget.state.profile!.userName,
        context,
        () {
          widget.state.likeProfile();
          _likeController.forward(from: 0);
          _dislikeController.reverse(from: widget.state.dislikeIconUpperBound);
        },
      );
    } else {
      // remove the match
      widget.state.removeProfileMatch();
      _likeController.reverse();
      _dislikeController.forward(from: 0);
      widget.deleteMatch(widget.state.profile!.id!);
    }
  }
}
