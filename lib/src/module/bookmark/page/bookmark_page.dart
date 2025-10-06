import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/match_action_widget_mixin.dart';
import '../../base/service/localization_service.dart';
import '../../dashboard/page/widget/conversation/dashboard_conversation_widget_mixin.dart';
import '../../message/message_config.dart';
import '../service/model/bookmark_model.dart';
import 'state/bookmark_state.dart';
import 'style/bookmark_page_style.dart';
import 'widget/bookmark_nothing_found_widget.dart';
import 'widget/bookmark_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class BookmarkPage extends AbstractPage
    with MatchActionWidgetMixin, DashboardConversationWidgetMixin {
  const BookmarkPage({
    Key? key,
    required Map<String, dynamic>? routeParams,
    required Map<String, dynamic>? widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
    with SingleTickerProviderStateMixin {
  late final BookmarkState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<BookmarkState>();
    _state.init();

    widget.logViewList('bookmark-list');
  }

  @override
  void dispose() {
    super.dispose();
    _state.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        scrollable: false,
        header: LocalizationService.of(context).t(
          'bookmarks_page_header',
        ),
        backgroundColor: !_state.isPageLoaded
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
        body: _state.isPageLoaded ? _bookmarksPage() : BookmarkSkeletonWidget(),
      ),
    );
  }

  Widget _bookmarksPage() {
    final bookmarkUser = _state.getBookmarkUsers();

    // nothing found
    if (bookmarkUser.isEmpty) {
      return BookmarkNothingFoundWidget();
    }

    return bookmarkPageWrapperContainer(
      ListView.builder(
        itemCount: bookmarkUser.length,
        cacheExtent: MediaQuery.of(context).size.height * 2,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            key: Key(index.toString()),
            direction: Axis.horizontal,
            // actionPane: SlidableScrollActionPane(),
            child: userListItemRow(
              context,
              bookmarkUser[index].user,
              () => _showProfilePage(bookmarkUser[index]),
            ),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(onDismissed: () {}),
              children: _getMainActions(bookmarkUser[index]),
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(onDismissed: () {}),
              children: _getSecondaryActions(bookmarkUser[index]),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getMainActions(BookmarkModel bookmarkUser) {
    if (!widget.isRtlMode(context)) {
      return [];
    }

    return _getAllActions(bookmarkUser);
  }

  List<Widget> _getSecondaryActions(BookmarkModel bookmarkUser) {
    if (widget.isRtlMode(context)) {
      return [];
    }

    return _getAllActions(bookmarkUser);
  }

  List<Widget> _getAllActions(BookmarkModel bookmarkUser) {
    return [
      // display a like button
      if (bookmarkUser.user.matchAction == null)
        bookmarkPageLikeActionContainer(
          LocalizationService.of(context).t('like'),
          () => _likeProfile(bookmarkUser),
        ),
      // display a chat button
      if (widget.isChatAllowed(bookmarkUser.user))
        bookmarkPageSendMessageActionContainer(
          LocalizationService.of(context).t('send_message'),
          () => _showChatPage(bookmarkUser.user.id),
        ),

      // remove from the bookmarks
      bookmarkPageRemoveActionContainer(
        LocalizationService.of(context).t('unmark'),
        () => _unmarkProfile(bookmarkUser),
      ),
    ];
  }

  void _likeProfile(BookmarkModel bookmarkUser) {
    widget.likeUser(
      bookmarkUser.user.id!,
      bookmarkUser.user.userName,
      context,
      () => _state.likeProfile(bookmarkUser),
    );
  }

  void _showChatPage(int? profileId) {
    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        MESSAGES_MAIN_URL,
        ['userId'],
        [profileId],
      ),
    );
  }

  void _showProfilePage(BookmarkModel bookmarkUser) {
    widget.redirectToProfilePage(
      context,
      bookmarkUser.user.id,
    );
  }

  void _unmarkProfile(BookmarkModel bookmarkUser) {
    widget.showConfirmation(
      context,
      'delete_bookmark_confirmation',
      () {
        _state.unmarkProfile(bookmarkUser);
        widget.showMessage('profile_removed_from_bookmarks', context);
      },
    );
  }
}
