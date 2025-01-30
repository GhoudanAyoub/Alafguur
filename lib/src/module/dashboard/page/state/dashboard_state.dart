import 'dart:async';
import 'dart:convert';

import 'package:application/src/module/base/service/user_service.dart';
import 'package:browser_detector/browser_detector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../base/page/state/device_info_state.dart';
import '../../../base/page/state/firebase_state.dart';
import '../../../base/page/state/page_visibility_state.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/localization_service.dart';
import '../../../guest/page/state/guest_state.dart';
import '../../../payment/page/state/payment_in_app_purchase_state.dart';
import '../../../payment/page/state/payment_state.dart';
import '../../../payment/payment_config.dart';
import '../../../video_im/page/state/video_im_state.dart';
import '../../../video_im/service/model/video_im_call_data_model.dart';
import '../../../video_im/service/model/video_im_notification_model.dart';
import '../../service/model/dashboard_matched_user_model.dart';
import 'dashboard_conversation_state.dart';
import 'dashboard_menu_state.dart';
import 'dashboard_user_state.dart';

part 'dashboard_state.g.dart';

typedef OnVideoImOfferCallback = Function(VideoImCallDataModel offer);
typedef OnVideoImActiveCallCallback = Function(VideoImCallDataModel call);
typedef OnNewMatchedUserCallback = Function(DashboardMatchedUserModel call);
typedef OnPushNotificationCallback = void Function(RemoteMessage message);
typedef OnPageVisibilityChangeCallback = void Function(
  PageVisibility visibility,
);
typedef OnDashboardPageNavigatedCallback = Function(int? pageIndex);

class DashboardState = _DashboardState with _$DashboardState;

abstract class _DashboardState with Store {
  final LocalizationService localizationService;
  final SharedPreferences sharedPreferences;
  final BrowserDetector browserDetector;
  final RootState rootState;
  final FirebaseState firebaseState;
  final DashboardUserState dashboardUserState;
  final VideoImState videoImState;
  final DashboardConversationState dashboardConversationState;
  final DeviceInfoState deviceInfoState;
  final PageVisibilityState pageVisibilityState;
  final String firebaseVapidKey;
  final GuestState guestState;
  final DashboardMenuState dashboardMenuState;
  final PaymentInAppPurchaseState inAppPurchaseState;
  final PaymentState paymentState;
  final UserService userService;

  int _permissionsUpdateTime = 0;

  final String _pushNotificationDataSharedPreferencesKey =
      'push_notification_data';

  final String _serverUpdatesPermissionsChannel = 'permissions';
  final String _serverUpdatesVideoImChannel = 'videoIm';
  final String _serverUpdatesMatchedUsersChannel = 'matchedUsers';
  final String _serverUpdatesConversationsChannel = 'conversations';
  final String _serverUpdatesGuestsChannel = 'guests';

  OnVideoImOfferCallback? _videoImOfferCallback;
  OnVideoImActiveCallCallback? _videoImActiveCallCallback;
  OnNewMatchedUserCallback? _newMatchedUserCallback;
  OnPushNotificationCallback? _onPushNotificationCallback;
  OnDashboardPageNavigatedCallback? _dashboardPageNavigatedCallback;

  Function? _paypalPaymentCallback;
  Function? _stripePaymentStatusCallback;

  late ReactionDisposer _serverUpdatesWatcherCancellation;
  late ReactionDisposer _authWatcherCancellation;
  late ReactionDisposer _videoImServerUpdatesCancellation;
  late ReactionDisposer _videoImOffersDisposer;
  late ReactionDisposer _videoImActiveCallDisposer;
  late ReactionDisposer _pageVisibilityDisposer;
  late ReactionDisposer _dashboardPagesNavigationDisposer;

  StreamSubscription? _pushMessageSubscription;
  StreamSubscription? _deviceTokenRefreshSubscription;

  /// FCM device token.
  String? _deviceToken = '';

  _DashboardState({
    required this.localizationService,
    required this.sharedPreferences,
    required this.browserDetector,
    required this.rootState,
    required this.firebaseState,
    required this.dashboardUserState,
    required this.videoImState,
    required this.dashboardConversationState,
    required this.deviceInfoState,
    required this.pageVisibilityState,
    required this.firebaseVapidKey,
    required this.guestState,
    required this.dashboardMenuState,
    required this.inAppPurchaseState,
    required this.paymentState,
    required this.userService,
  });

  /// Handle background message reception.
  void onFirebaseMessage(RemoteMessage message) {
    if (_onPushNotificationCallback != null) {
      _onPushNotificationCallback!(message);
    }
  }

  void setDashboardPageNavigatedCallback(
    OnDashboardPageNavigatedCallback dashboardPageNavigatedCallback,
  ) {
    _dashboardPageNavigatedCallback = dashboardPageNavigatedCallback;
  }

  /// Handle completed native purchases using [purchaseCompletedCallback].
  void setNativePurchaseCompletedCallback(
    PaymentNativePurchaseCompletedCallback purchaseCompletedCallback,
  ) {
    inAppPurchaseState.onPurchaseCompletedCallback = purchaseCompletedCallback;
  }

  /// Handle pending native purchases using [purchasePendingCallback].
  void setNativePurchasePendingCallback(
    PaymentNativePurchaseCallback purchasePendingCallback,
  ) {
    inAppPurchaseState.onPurchaseStatusPendingCallback =
        purchasePendingCallback;
  }

  /// Handle native purchases with error status using [purchaseErrorCallback].
  void setNativePurchaseErrorCallback(
    PaymentNativePurchaseCallback purchaseErrorCallback,
  ) {
    inAppPurchaseState.onPurchaseStatusErrorCallback = purchaseErrorCallback;
  }

  /// Handle invalid native purchases using [purchaseInvalidCallback].
  void setNativePurchaseInvalidCallback(
      PaymentNativePurchaseValidationResultCallback purchaseInvalidCallback,
  ) {
    inAppPurchaseState.onPurchaseInvalidCallback = purchaseInvalidCallback;
  }

  /// Handle native purchase plugin exception using [purchaseExceptionCallback].
  void setNativePurchaseExceptionCallback(
    PaymentNativePurchaseExceptionCallback purchaseExceptionCallback,
  ) {
    inAppPurchaseState.onPurchaseExceptionCallback = purchaseExceptionCallback;
  }

  /// Handle PayPal payment state using [paypalPaymentCallback].
  void setPaypalPaymentCallback(Function paypalPaymentCallback) {
    _paypalPaymentCallback = paypalPaymentCallback;
  }

  /// Handle Stripe payment status change using [stripePaymentStatusCallback].
  void setStripePaymentStatusCallback(Function stripePaymentStatusCallback) {
    _stripePaymentStatusCallback = stripePaymentStatusCallback;
  }

  /// pre initialize (watchers, etc)
  void init() async {
    // init watchers
    _initServerUpdatesWatcher();
    _initAuthWatcher();
    _initVideoImServerUpdatesWatcher();
    _initVideoImOffersWatcher();
    _initVideoImActiveCallWatcher();
    _initPageVisibilityWatcher();
    _initDashboardPagesNavigationWatcher();

    _initVideoImState();
    _initPageVisibilityState();
    _initFirebaseMessaging();
    _initInAppPurchases();

    // Check if initial notification is available.
    _checkForInitialNotification();

    // Check whether PayPal payment flag is set.
    _checkForPaypalPaymentFlag();

    // Check Stripe payment status.
    _checkStripePaymentStatus();

    dashboardConversationState.init();
    guestState.init();

    // initial loading of the user's data
    if (dashboardUserState.user == null) {
      _loadUserData();

      dashboardUserState.loadUserLocation();
    }

    // if (rootState.isPluginAvailable('redirecttosubscribe')) {
    //   final server_rts = await userService.redirectToSubscribe();
    //   sharedPreferences.setBool(REDIRECT_TO_SUBSCRIBE, server_rts);
    // }
  }

  /// Call user using the given [callData].
  void videoImCallUser(VideoImCallDataModel callData) {
    videoImState.callWithData(callData);
  }

  /// Get video IM session ID.
  String getVideoImSessionId() {
    return videoImState.generateSessionId();
  }

  /// unsubscribe watchers and clean resources
  @action
  void dispose() {
    _serverUpdatesWatcherCancellation();
    _authWatcherCancellation();

    _videoImServerUpdatesCancellation();
    _videoImOffersDisposer();
    _videoImActiveCallDisposer();
    _pageVisibilityDisposer();
    _dashboardPagesNavigationDisposer();

    dashboardConversationState.dispose();
    videoImState.dispose();
    guestState.dispose();
    inAppPurchaseState.dispose();

    _pushMessageSubscription?.cancel();
    _deviceTokenRefreshSubscription?.cancel();
  }

  Future<void> markMatchedUserAsRead(
    DashboardMatchedUserModel matchedUser,
  ) async {
    return dashboardConversationState.markMatchedUserAsRead(matchedUser);
  }

  /// Causes any active payment widgets to update their content.
  void updatePaymentWidgets() {
    paymentState.updateWidgets();
  }

  /// Mark pending native purchase as completed.
  void markPendingNativePurchaseAsCompleted() {
    paymentState.markPendingNativePurchaseAsCompleted();
  }

  /// watch server updates
  void _initServerUpdatesWatcher() {
    _serverUpdatesWatcherCancellation = reaction(
      (_) => rootState.serverUpdates,
      (dynamic _) {
        // we need to know the last update time of the permission channel
        int? lastPermissionsChannelUpdateTime = rootState
            .getServerUpdatesLastUpdateTime(_serverUpdatesPermissionsChannel);

        // process the user's permissions
        if (dashboardUserState.user != null) {
          _processUserPermissions(
            lastPermissionsChannelUpdateTime,
            rootState.getServerUpdates(
              _serverUpdatesPermissionsChannel,
            ),
          );
        }

        // update both conversations and matched users
        dashboardConversationState.updateMatchedUsers(
          rootState.getServerUpdates(
            _serverUpdatesMatchedUsersChannel,
          ),
        );

        dashboardConversationState.updateConversations(
          rootState.getServerUpdates(
            _serverUpdatesConversationsChannel,
          ),
        );

        // update the guest list
        guestState.updateGuests(
          rootState.getServerUpdates(
            _serverUpdatesGuestsChannel,
          ),
        );

        // both server updates and the user's data are loaded
        if (dashboardUserState.user != null) {
          dashboardUserState.isUserLoaded = true;
          _notifyAboutNewMatch();
        }
      },
    );
  }

  /// watch the auth state
  void _initAuthWatcher() {
    _authWatcherCancellation =
        reaction((_) => rootState.isAuthenticated, (dynamic isAuthenticated) {
      // clean the current user's data
      if (!isAuthenticated) {
        dashboardUserState.user = null;
        dashboardUserState.isUserLoaded = false;
        _permissionsUpdateTime = 0;
      }
    });
  }

  /// Initialize Video IM state.
  void _initVideoImState() {
    videoImState.init();
  }

  /// Initialize page visibility state.
  void _initPageVisibilityState() {
    pageVisibilityState.init();
  }

  /// Initialize Firebase Cloud Messaging subscription.
  void _initFirebaseMessaging() async {
    // Ignore Safari (desktop included) and all iOS browsers.
    if (browserDetector.platform.isIOS || browserDetector.browser.isSafari) {
      return;
    }

    // The getFcmToken call below will throw an exception if the notification
    // permission was denied.
    try {
      _deviceToken =
          await firebaseState.getFcmToken(vapidKey: firebaseVapidKey);

      if (_deviceToken == null) {
        return;
      }

      _pushMessageSubscription =
          firebaseState.setOnMessageCallback(onFirebaseMessage);

      _deviceTokenRefreshSubscription =
          firebaseState.setOnFcmTokenRefreshCallback(_onDeviceTokenRefresh);

      firebaseState.registerDevice(
        deviceId: (await deviceInfoState.uuid)!,
        fcmToken: _deviceToken!,
        platform: deviceInfoState.platform,
        language: localizationService.languageCode,
      );
    } catch (_) {
      // Just ignore it.
      return;
    }
  }

  /// Initialize native purchases.
  void _initInAppPurchases() {
    if (!kIsWeb && !rootState.isDemoModeActivated) {
      inAppPurchaseState.init();
    }
  }

  /// watch Video IM notifications
  void _initVideoImServerUpdatesWatcher() {
    _videoImServerUpdatesCancellation = reaction(
      (_) => rootState.serverUpdates,
      (dynamic _) {
        rootState.log(
          '[dashboard_state+video_im] received video im server updates',
        );

        final List? notificationsRaw = rootState.getServerUpdates(
          _serverUpdatesVideoImChannel,
        );

        if (notificationsRaw != null && notificationsRaw.isNotEmpty) {
          final List<VideoImNotificationModel> notifications = notificationsRaw
              .map(
                (notification) => VideoImNotificationModel.fromJson(
                  notification,
                ),
              )
              .toList();

          videoImState.processNotifications(notifications);
        }
      },
    );
  }

  /// Init Video IM incoming offers watcher.
  void _initVideoImOffersWatcher() {
    _videoImOffersDisposer = reaction(
      (_) => videoImState.offers,
      (dynamic offers) {
        if (offers.isNotEmpty && _videoImOfferCallback != null) {
          final offer = offers.last;

          if (offer.role == VideoImCallRole.interlocutor) {
            _videoImOfferCallback!(offer);
          }
        }
      },
    );
  }

  /// Init Video IM active call watcher.
  void _initVideoImActiveCallWatcher() {
    _videoImActiveCallDisposer = reaction(
      (_) => videoImState.activeCall,
      (dynamic activeCall) {
        if (activeCall != null && _videoImActiveCallCallback != null) {
          _videoImActiveCallCallback!(activeCall);
        }
      },
    );
  }

  /// Initialize page visibility change watcher.
  void _initPageVisibilityWatcher() {
    _pageVisibilityDisposer = reaction(
      (_) => pageVisibilityState.visibility,
      (dynamic _) async {
        if (!kIsWeb ||
            browserDetector.platform.isIOS ||
            browserDetector.browser.isSafari ||
            pageVisibilityState.visibility != PageVisibility.visible) {
          return;
        }

        // Update shared preferences cache.
        await sharedPreferences.reload();

        final containsKey = sharedPreferences.containsKey(
          _pushNotificationDataSharedPreferencesKey,
        );

        if (containsKey && _onPushNotificationCallback != null) {
          final dataStr =
              sharedPreferences.get(_pushNotificationDataSharedPreferencesKey);

          var notification;

          if (dataStr.runtimeType == String) {
            notification = jsonDecode(dataStr as String);
          } else {
            notification = dataStr;
          }

          sharedPreferences.remove(_pushNotificationDataSharedPreferencesKey);

          _onPushNotificationCallback!(
            RemoteMessage(data: notification['data']),
          );
        }
      },
    );
  }

  void _initDashboardPagesNavigationWatcher() {
    _dashboardPagesNavigationDisposer = reaction(
      (_) => dashboardMenuState.pageIndexes,
      (dynamic _) {
        return _dashboardPageNavigatedCallback?.call(
          dashboardMenuState.pageIndex,
        );
      },
    );
  }

  /// load user's data
  @action
  Future<void> _loadUserData() async {
    await dashboardUserState.loadUser();

    if (rootState.isServerUpdatesLoaded) {
      dashboardUserState.isUserLoaded = true;
      _notifyAboutNewMatch();
    }
  }

  /// Set Video IM incoming offer callback.
  void setVideoImOfferCallback(OnVideoImOfferCallback videoImOfferCallback) {
    _videoImOfferCallback = videoImOfferCallback;
  }

  /// Set Video IM active call callback.
  void setVideoImActiveCallCallback(
    OnVideoImActiveCallCallback videoImActiveCallCallback,
  ) {
    _videoImActiveCallCallback = videoImActiveCallCallback;
  }

  /// Set new matched user callback.
  void setNewMatchedUserCallback(
    OnNewMatchedUserCallback? newMatchedUserCallback,
  ) {
    _newMatchedUserCallback = newMatchedUserCallback;
  }

  /// Set Push notification callback.
  void setPushNotificationCallback(
    OnPushNotificationCallback pushNotificationCallback,
  ) {
    _onPushNotificationCallback = pushNotificationCallback;
  }

  /// process received user permissions
  void _processUserPermissions(
    int? lastChannelUpdateTime,
    List? permissions,
  ) {
    if (lastChannelUpdateTime != null &&
        lastChannelUpdateTime > _permissionsUpdateTime) {
      // retain the last permission update time
      _permissionsUpdateTime = lastChannelUpdateTime;
      dashboardUserState.updateUserPermissions(permissions!);
    }
  }

  void _notifyAboutNewMatch() {
    // a notification about a new matched user
    if (_newMatchedUserCallback != null) {
      final newMatchedUser =
          dashboardConversationState.getFirstNewMatchedUser();

      if (newMatchedUser != null) {
        _newMatchedUserCallback!(newMatchedUser);
      }
    }
  }

  /// Device token refresh event handler.
  void _onDeviceTokenRefresh(String newToken) async {
    _deviceToken = newToken;

    firebaseState.registerDevice(
      deviceId: (await deviceInfoState.uuid)!,
      fcmToken: newToken,
      platform: deviceInfoState.platform,
      language: localizationService.languageCode,
    );
  }

  /// Check whether there is an initial notification stored, call push
  /// notification handler if there is.
  ///
  /// Initial notification is a notification that was used to restart the app
  /// from the terminated state. This notification is stored in special buffer
  /// and can be consumed and handled when the app is started.
  void _checkForInitialNotification() async {
    final notification = await firebaseState.messaging?.getInitialMessage();

    if (notification != null && _onPushNotificationCallback != null) {
      _onPushNotificationCallback!(notification);
    }
  }

  /// Check whether PayPal payment completion flag is set, trigger handler
  /// callbacks.
  Future<void> _checkForPaypalPaymentFlag() async {
    if (!kIsWeb) {
      return;
    }

    if (sharedPreferences.containsKey(PAYPAL_PAYMENT_COMPLETED_FLAG)) {
      final result = sharedPreferences.getBool(PAYPAL_PAYMENT_COMPLETED_FLAG);
      await sharedPreferences.remove(PAYPAL_PAYMENT_COMPLETED_FLAG);

      _paypalPaymentCallback?.call(result);
    }
  }

  /// Check whether the Stripe payment status info is present in local storage
  /// and, if it is, trigger the handler callback.
  Future<void> _checkStripePaymentStatus() async {
    if (!kIsWeb) {
      return;
    }

    if (sharedPreferences.containsKey(STRIPE_STATUS_PARAMETER_FLAG)) {
      final status = sharedPreferences.getString(STRIPE_STATUS_PARAMETER_FLAG);
      await sharedPreferences.remove(STRIPE_STATUS_PARAMETER_FLAG);

      _stripePaymentStatusCallback?.call(status);
    }
  }

  bool? getRedirectToSubscribe() {
    if (rootState.isPluginAvailable('redirecttosubscribe')) {
      if (sharedPreferences.containsKey(REDIRECT_TO_SUBSCRIBE)) {
        var rts = sharedPreferences.getBool(REDIRECT_TO_SUBSCRIBE);
        sharedPreferences.setBool(REDIRECT_TO_SUBSCRIBE, false);
        return rts;
      }
    }

    sharedPreferences.setBool(REDIRECT_TO_SUBSCRIBE, false);
    return false;
  }

  bool? getShowingPopup() {
    if (rootState.isPluginAvailable('popupmessages')) {
      if (sharedPreferences.containsKey(SHOWING_POPUP)) {
        var sp = sharedPreferences.getBool(SHOWING_POPUP);
        sharedPreferences.setBool(SHOWING_POPUP, false);
        return sp;
      }
    }

    sharedPreferences.setBool(SHOWING_POPUP, false);
    return false;
  }
}
