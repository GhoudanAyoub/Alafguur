import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/base_config.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../../../bookmark/bookmark_config.dart';
import '../../../../compatible_user/compatible_user_config.dart';
import '../../../../edit/edit_config.dart';
import '../../../../guest/guest_config.dart';
import '../../../../installation_guide/installation_guide_config.dart';
import '../../../../settings/settings_config.dart';
import '../../state/dashboard_profile_state.dart';
import '../../style/profile/dashboard_profile_widget_style.dart';
import 'dashboard_profile_skeleton_widget.dart';

class DashboardProfileWidget extends StatefulWidget
    with NavigationWidgetMixin, ModalWidgetMixin {
  @override
  _DashboardProfileWidgetState createState() => _DashboardProfileWidgetState();
}

class _DashboardProfileWidgetState extends State<DashboardProfileWidget> {
  late final DashboardProfileState _state;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<DashboardProfileState>();

    // we need to restore the scroll position every time when the page is active
    _scrollController =
        ScrollController(initialScrollOffset: _state.scrollOffset);

    _scrollController.addListener(
      () => _state.scrollOffset = _scrollController.offset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) =>
          !_state.isPageLoaded ? DashboardProfileSkeletonWidget() : _profile(),
    );
  }

  Widget _profile() {
    return dashboardProfileWidgetWrapperContainer(
      _scrollController,
      [
        dashboardProfileWidgetInfoWrapperContainer(
          context,
          // an avatar
          dashboardProfileWidgetAvatarContainer(
            context,
            _state.user!.avatar,
            () => widget.redirectToProfilePage(
              context,
              _state.user!.id,
            ),
          ),
          // a user name
          dashboardProfileWidgetUserNameContainer(_state.user!.userName),
          // a description
          dashboardProfileWidgetUserDescContainer(_state.user!.aboutMe),
          // edit and settings buttons
          dashboardProfileWidgetButtonsWrapperContainer(
            LocalizationService.of(context).t('profile_edit_profile'),
            () => _pushEditPage(),
            LocalizationService.of(context).t('profile_app_settings'),
            () => _pushSettingsPage(),
            context,
          ),
        ),
        dashboardProfileWidgetPageLinksWrapperContainer(
          [
            // a buy upgrades link
            if (_state.isPaymentsAvailable)
              dashboardProfileWidgetPageLinkContainer(
                LocalizationService.of(context).t('profile_buy_upgrades'),
                    () => _pushPaymentInitialPage(),
              ),

            // an installation guide link
            if (_state.isInstallationGuideAvailable)
              dashboardProfileWidgetGuideLinkContainer(
                LocalizationService.of(context).t('pwa_installation_guide'),
                () => _pushInstallationGuidePage(),
              ),

            // a guests link
            if (_state.isGuestsAvailable)
              dashboardProfileWidgetGuestsLinkContainer(
                LocalizationService.of(context).t('profile_my_guests'),
                () => _pushGuestsPage(),
                _state.newGuests,
              ),

            // a bookmarks link
            if (_state.isBookmarksAvailable)
              dashboardProfileWidgetPageLinkContainer(
                LocalizationService.of(context).t('profile_bookmarks'),
                () => _pushBookmarksPage(),
              ),

            // a compatible users link
            if (_state.isMatchmakingAvailable)
              dashboardProfileWidgetPageLinkContainer(
                LocalizationService.of(context).t('profile_compatible_users'),
                () => _pushCompatibleUsersPage(),
              ),
          ],
        ),
      ],
    );
  }

  void _pushGuestsPage() {
    Navigator.pushNamed(context, GUESTS_MAIN_URL);
  }

  void _pushBookmarksPage() {
    Navigator.pushNamed(context, BOOKMARKS_MAIN_URL);
  }

  void _pushCompatibleUsersPage() {
    Navigator.pushNamed(context, COMPATIBLE_USERS_MAIN_URL);
  }

  void _pushEditPage() {
    Navigator.pushNamed(context, EDIT_MAIN_URL);
  }

  void _pushSettingsPage() {
    Navigator.pushNamed(context, SETTINGS_MAIN_URL);
  }

  void _pushInstallationGuidePage() {
    Navigator.pushNamed(context, INSTALLATION_GUIDE_MAIN_URL);
  }

  void _pushPaymentInitialPage() async {
    if (!kIsWeb && !_state.isNativeStoreInitialized) {
      widget.showAlert(context, 'payment_native_store_not_available');

      return;
    }

    Navigator.pushNamed(context, BASE_PAYMENT_URL);
  }
}
