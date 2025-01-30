import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../base/page/state/root_state.dart';
import 'dashboard_conversation_state.dart';

part 'dashboard_menu_state.g.dart';

const ACTIVE_PAGE_INDEX = 'active_dashboard_page_index';
const ACTIVE_SUB_PAGE_INDEX = 'active_dashboard_sub_page_index';

enum DashboardPagesEnum {
  profile,
  middleware_search,
  conversation,
}

enum DashboardSubPagesEnum {
  hotList,
  tinder,
  browse,
}

class DashboardMenuState = _DashboardMenuState with _$DashboardMenuState;

abstract class _DashboardMenuState with Store {
  final RootState rootState;
  final SharedPreferences sharedPreferences;
  final DashboardConversationState dashboardConversationState;

  @observable
  int? pageIndex;

  @observable
  int? subPageIndex;

  @computed
  String get pageIndexes => '$pageIndex, $subPageIndex';

  final Map _pagesIndexMap = {
    DashboardPagesEnum.profile: 0,
    DashboardPagesEnum.middleware_search: 1,
    DashboardPagesEnum.conversation: 2,
  };

  final Map _subPagesIndexMap = {
    DashboardSubPagesEnum.hotList: 0,
    DashboardSubPagesEnum.tinder: 1,
    DashboardSubPagesEnum.browse: 2,
  };

  _DashboardMenuState({
    required this.rootState,
    required this.sharedPreferences,
    required this.dashboardConversationState,
  }) {
    // init previously saved settings
    pageIndex = sharedPreferences.getInt(ACTIVE_PAGE_INDEX) ?? 0;
    subPageIndex = sharedPreferences.getInt(ACTIVE_SUB_PAGE_INDEX) ?? 0;
  }

  @action
  void setPageByIndex(int index) {
    if (index > 2) {
      throw Exception('Wrong page index is used');
    }

    sharedPreferences.setInt(ACTIVE_PAGE_INDEX, index);
    pageIndex = index;
  }

  @action
  void navigateToPage(
    page, {
    DashboardSubPagesEnum? subPage,
  }) {
    pageIndex = _pagesIndexMap[page];
    sharedPreferences.setInt(ACTIVE_PAGE_INDEX, pageIndex!);

    if (subPage != null) {
      subPageIndex = _subPagesIndexMap[subPage];
      sharedPreferences.setInt(ACTIVE_SUB_PAGE_INDEX, subPageIndex!);
    }
  }

  bool isPageActive(DashboardPagesEnum page) {
    return _pagesIndexMap[page] == pageIndex;
  }

  bool isSubPageActive(DashboardSubPagesEnum? subPage) {
    return _subPagesIndexMap[subPage] == subPageIndex;
  }

  bool get newMessages =>
      dashboardConversationState.getUnreadConversationsCount() > 0;

  bool get newMatchedUsers =>
      dashboardConversationState.getNewMatchedUsersCount() > 0;

  bool get isHotListSubPageAllowed => rootState.isPluginAvailable('hotlist');

  bool get isTinderCardsSubPageAllowed =>
      rootState.isAppTinderMode || rootState.isAppBothMode;

  bool get isBrowseSubPageAllowed =>
      rootState.isAppBrowseMode || rootState.isAppBothMode;
}
