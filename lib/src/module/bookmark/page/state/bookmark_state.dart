import 'package:mobx/mobx.dart';

import '../../../../app/service/random_service.dart';
import '../../../base/service/bookmark_profile_service.dart';
import '../../../base/service/model/user_match_action_model.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../service/model/bookmark_model.dart';

part 'bookmark_state.g.dart';

class BookmarkState = _BookmarkState with _$BookmarkState;

abstract class _BookmarkState with Store {
  final DashboardUserState dashboardUserState;
  final RandomService randomService;
  final BookmarkProfileService bookmarkProfileService;

  @observable
  bool isPageLoaded = false;

  @observable
  List<BookmarkModel> bookmarkUsers = [];

  late ReactionDisposer _userLoadedUpdatesWatcherCancellation;
  late ReactionDisposer _lastChangedProfileWatcherCancellation;

  _BookmarkState({
    required this.dashboardUserState,
    required this.randomService,
    required this.bookmarkProfileService,
  });

  @action
  Future<void> init() async {
    // load bookmark users
    final List? bookmarks = await bookmarkProfileService.loadBookmarks();

    bookmarkUsers =
        bookmarks!.map((bookmark) => BookmarkModel.fromJson(bookmark as Map<String, dynamic>)).toList();

    if (dashboardUserState.isUserLoaded) {
      isPageLoaded = true;
    }

    // init watchers
    _initUserLoadedUpdatesWatcher();
    _initLastChangedProfileWatcher();
  }

  void dispose() {
    _userLoadedUpdatesWatcherCancellation();
    _lastChangedProfileWatcherCancellation();
  }

  List<BookmarkModel> getBookmarkUsers() {
    return bookmarkUsers
        .where((bookmarkUser) => bookmarkUser.user.bookmark != null)
        .toList();
  }

  @action
  void unmarkProfile(
    BookmarkModel deleteableBookmarkUser,
  ) {
    // refresh the bookmark list
    bookmarkUsers = bookmarkUsers
        .where((bookmarkUser) => bookmarkUser.id != deleteableBookmarkUser.id)
        .toList();

    bookmarkProfileService.unbookmarkProfile(deleteableBookmarkUser.user.id);
  }

  void likeProfile(BookmarkModel bookmarkUser) {
    final clonedBookmarkUser = _cloneBookmarkUser(bookmarkUser);

    // add a new match
    clonedBookmarkUser.user.matchAction = UserMatchActionModel(
      id: randomService.integer(),
      userId: bookmarkUser.user.id!,
      type: MatchActionTypeEnum.like,
    );

    // notify listeners about changes
    dashboardUserState.lastChangedProfile = clonedBookmarkUser.user;
  }

  /// watch user loaded updates
  void _initUserLoadedUpdatesWatcher() {
    _userLoadedUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.isUserLoaded, (dynamic _) {
      isPageLoaded = true;
    });
  }

  /// watch last changed profile
  void _initLastChangedProfileWatcher() {
    _lastChangedProfileWatcherCancellation =
        reaction((_) => dashboardUserState.lastChangedProfile, (dynamic _) {
      // synchronize the latest profile's changes with the bookmark list
      bookmarkUsers = bookmarkUsers.map((bookmarkUser) {
        if (bookmarkUser.user.id != dashboardUserState.lastChangedProfile!.id) {
          return bookmarkUser;
        }

        final clonedBookmarkUser = _cloneBookmarkUser(bookmarkUser);
        clonedBookmarkUser.user =
            dashboardUserState.mergeLastChangedProfile(clonedBookmarkUser.user);

        return clonedBookmarkUser;
      }).toList();
    });
  }

  BookmarkModel _cloneBookmarkUser(
    BookmarkModel bookmarkUser,
  ) {
    return BookmarkModel.fromJson(bookmarkUser.toJson());
  }
}
