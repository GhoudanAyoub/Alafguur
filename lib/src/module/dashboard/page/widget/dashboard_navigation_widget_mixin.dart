import 'package:get_it/get_it.dart';

import '../state/dashboard_menu_state.dart';

mixin DashboardNavigationWidgetMixin {
  bool isDashboardProfilePageActive() {
    return _state.isPageActive(DashboardPagesEnum.profile);
  }

  void navigateDashboardToProfilePage() {
    _state.navigateToPage(DashboardPagesEnum.profile);
  }

  bool isDashboardMiddlewareSearchPageActive() {
    return _state.isPageActive(DashboardPagesEnum.middleware_search);
  }

  bool get isHotListSubPageAllowed => _state.isHotListSubPageAllowed;

  void navigateDashboardToHotListSubPage() {
    _state.navigateToPage(
      DashboardPagesEnum.middleware_search,
      subPage: DashboardSubPagesEnum.hotList,
    );
  }

  bool get isTinderCardsSubPageAllowed => _state.isTinderCardsSubPageAllowed;

  void navigateDashboardToTinderCardsSubPage() {
    _state.navigateToPage(
      DashboardPagesEnum.middleware_search,
      subPage: DashboardSubPagesEnum.tinder,
    );
  }

  bool get isBrowseSubPageAllowed => _state.isBrowseSubPageAllowed;

  void navigateDashboardToBrowseSubPage() {
    _state.navigateToPage(
      DashboardPagesEnum.middleware_search,
      subPage: DashboardSubPagesEnum.browse,
    );
  }

  bool isDashboardConversationPageActive() {
    return _state.isPageActive(DashboardPagesEnum.conversation);
  }

  void navigateDashboardToConversationPage() {
    _state.navigateToPage(DashboardPagesEnum.conversation);
  }

  void setDashboardPageByIndex(int pageIndex) {
    _state.setPageByIndex(pageIndex);
  }

  int? getDashboardPageIndex() {
    return _state.pageIndex;
  }

  bool get newMessages => _state.newMessages;

  bool get newMatchedUsers => _state.newMatchedUsers;

  DashboardSubPagesEnum? getActiveSubPageName({
    bool checkMainPage = true,
  }) {
    // check if the hot list is activated
    if (isHotListSubPageAllowed &&
        _isDashboardSubPageActive(
          subPage: DashboardSubPagesEnum.hotList,
          checkMainPage: checkMainPage,
        )) {
      return DashboardSubPagesEnum.hotList;
    }

    // check if the tinder cards is activated
    if (isTinderCardsSubPageAllowed &&
        _isDashboardSubPageActive(
          subPage: DashboardSubPagesEnum.tinder,
          checkMainPage: checkMainPage,
        )) {
      return DashboardSubPagesEnum.tinder;
    }

    // check if the browse is activated
    if (isBrowseSubPageAllowed &&
        _isDashboardSubPageActive(
          subPage: DashboardSubPagesEnum.browse,
          checkMainPage: checkMainPage,
        )) {
      return DashboardSubPagesEnum.browse;
    }

    // find a default widget if there are no any active sub pages
    if (_state.isPageActive(DashboardPagesEnum.middleware_search) ||
        !checkMainPage) {
      if (isHotListSubPageAllowed) {
        return DashboardSubPagesEnum.hotList;
      }

      if (isTinderCardsSubPageAllowed) {
        return DashboardSubPagesEnum.tinder;
      }

      return DashboardSubPagesEnum.browse;
    }

    return null;
  }

  int getSubPageMenuElementOffset({
    int step = 50,
  }) {
    int initialPosition = 1;
    final Map<DashboardSubPagesEnum, int> elementPositions = {};

    if (isHotListSubPageAllowed) {
      elementPositions[DashboardSubPagesEnum.hotList] = initialPosition;
      initialPosition++;
    }

    if (isTinderCardsSubPageAllowed) {
      elementPositions[DashboardSubPagesEnum.tinder] = initialPosition;
      initialPosition++;
    }

    if (isBrowseSubPageAllowed) {
      elementPositions[DashboardSubPagesEnum.browse] = initialPosition;
    }

    if (elementPositions[getActiveSubPageName()!] != null) {
      return elementPositions[getActiveSubPageName()!]! * step - step;
    }

    return 0;
  }

  bool _isDashboardSubPageActive({
    DashboardSubPagesEnum? subPage,
    bool checkMainPage = true,
  }) {
    if (checkMainPage) {
      return _state.isPageActive(DashboardPagesEnum.middleware_search) &&
          _state.isSubPageActive(subPage);
    }

    return _state.isSubPageActive(subPage);
  }

  DashboardMenuState get _state => GetIt.instance.get<DashboardMenuState>();
}
