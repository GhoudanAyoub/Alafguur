import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobx/mobx.dart';

import '../../../base/base_config.dart';
import '../../../base/page/state/app_navigator_state.dart';
import '../../../base/page/state/root_state.dart';

part 'admob_state.g.dart';

class AdmobState = _AdmobState with _$AdmobState;

abstract class _AdmobState with Store {
  final RootState rootState;
  final AppNavigatorState appNavigatorState;

  late ReactionDisposer? _siteSettingsSubscription;
  StreamSubscription? _keyboardSubscription;

  static const _DASHBOARD_PAGE_NAME = 'dashboard';
  static const _LOGIN_PAGE_NAME = 'login';

  static const _ANDROID_AD_UNIT_ID_KEY = 'androidAdUnitId';
  static const _IOS_AD_UNIT_ID_KEY = 'iosAdUnitId';

  /// Proper ad unit ID key depending on the host platform.
  String get _adUnitIdKey {
    if (kIsWeb) {
      return '';
    }

    return Platform.isIOS ? _IOS_AD_UNIT_ID_KEY : _ANDROID_AD_UNIT_ID_KEY;
  }

  @observable
  bool isKeyboardOpened = false;

  /// True if ads are enabled globally.
  @observable
  bool isAdmobEnabled = false;

  /// Ad unit ID to display.
  @observable
  String adUnitId = '';

  /// PageId -> regex mapping for pages on which admob is enabled.
  @observable
  Map admobPages = {};

  /// True if the banner should be displayed.
  @computed
  bool get isBannerAvailable {
    if (kIsWeb || isKeyboardOpened || !isAdmobEnabled || adUnitId.isEmpty) {
      return false;
    }

    // check if the current page allows to display banners
    final currentPageName = appNavigatorState.currentPageName ?? '';
    bool isAdsEnabledOnCurrentPage = false;

    if (currentPageName == BASE_MAIN_URL) {
      isAdsEnabledOnCurrentPage = admobPages.containsKey(
        rootState.isAuthenticated! ? _DASHBOARD_PAGE_NAME : _LOGIN_PAGE_NAME,
      );

      return isAdsEnabledOnCurrentPage;
    }

    final match = admobPages.values
        .where(
          (regex) => regex != null,
        )
        .firstWhere(
          (regex) => RegExp(
            regex,
            caseSensitive: false,
            unicode: true,
          ).hasMatch(
            currentPageName,
          ),
          orElse: () => null,
        );

    isAdsEnabledOnCurrentPage = match != null;

    return isAdsEnabledOnCurrentPage;
  }

  /// Get new [BannerAd] instance.
  @computed
  BannerAd get newBanner {
    return BannerAd(
      size: _bannerSize,
      adUnitId: adUnitId,
      listener: BannerAdListener(),
      request: AdRequest(),
    );
  }

  /// Banner size.
  AdSize _bannerSize = AdSize.fullBanner;

  _AdmobState({
    required this.rootState,
    required this.appNavigatorState,
  });

  /// Initialize state.
  void init() {
    if (kIsWeb) {
      return;
    }

    // init watchers
    _initSiteSettingsUpdatesWatcher();
    _initKeyboardStatusWatcher();

    _updateAdSettings();
  }

  void dispose() {
    _siteSettingsSubscription?.call();
    _keyboardSubscription?.cancel();
  }

  /// watch settings updates state
  void _initSiteSettingsUpdatesWatcher() {
    _siteSettingsSubscription = reaction(
      (_) => rootState.siteSettings,
      (dynamic _) => _updateAdSettings(),
    );
  }

  /// watch keyboard status
  void _initKeyboardStatusWatcher() {
    final keyboardVisibilityController = KeyboardVisibilityController();

    _keyboardSubscription = keyboardVisibilityController.onChange.listen(
      (bool visible) {
        isKeyboardOpened = visible;
      },
    );
  }

  /// Update advertisement settings.
  @action
  void _updateAdSettings() {
    isAdmobEnabled = rootState.getSiteSetting('isAdmobEnabled', false);

    final newAdUnitId = rootState.getSiteSetting(_adUnitIdKey, '');

    if (adUnitId != newAdUnitId) {
      adUnitId = newAdUnitId;
    }

    admobPages = rootState.getSiteSetting('admobPages', {});
  }
}
