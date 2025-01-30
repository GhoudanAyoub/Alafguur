import 'dart:io';

import 'package:application/src/module/payment/page/widget/custom_payment_access_denied_widget.dart';
import 'package:application/src/module/payment/page/widget/custom_showing_popup_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/state/firebase_state.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/navigation_widget_mixin.dart';
import '../../message/message_config.dart';
import '../../payment/page/state/payment_in_app_purchase_state.dart';
import '../../payment/utility/payment_native_purchase_error_helper_utility.dart';
import '../../video_im/page/widget/video_im_accept_call_widget.dart';
import '../../video_im/page/widget/video_im_call_widget.dart';
import '../../video_im/service/model/video_im_call_data_model.dart';
import '../../video_im/service/model/video_im_call_widget_result_model.dart';
import '../service/model/dashboard_matched_user_model.dart';
import 'state/dashboard_state.dart';
import 'widget/conversation/dashboard_conversation_widget.dart';
import 'widget/dashboard_matched_user_widget.dart';
import 'widget/dashboard_middleware_search_widget.dart';
import 'widget/dashboard_navigation_widget_mixin.dart';
import 'widget/menu/dashboard_menu_widget.dart';
import 'widget/profile/dashboard_profile_widget.dart';

class DashboardPage extends AbstractPage
    with DashboardNavigationWidgetMixin, NavigationWidgetMixin {
  const DashboardPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  late final DashboardState _state;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DashboardState>();

    _state.setVideoImOfferCallback(_onNewVideoImOffer());
    _state.setVideoImActiveCallCallback(_onActiveVideoImCall());
    _state.setNewMatchedUserCallback(_onNewMatchedUser());
    _state.setPushNotificationCallback(_onPushNotification());
    _state.setDashboardPageNavigatedCallback(_onDashboardPageNavigated());

    // Set native purchases callbacks.
    _state.setNativePurchaseCompletedCallback(_onNativePurchaseCompleted());
    _state.setNativePurchasePendingCallback(_onNativePurchasePending());
    _state.setNativePurchaseInvalidCallback(_onNativePurchaseInvalidCallback());
    _state.setNativePurchaseErrorCallback(_onNativePurchaseErrorCallback());
    _state.setNativePurchaseExceptionCallback(
      _onNativePurchaseExceptionCallback(),
    );

    // Set PayPal payment completion callback.
    _state.setPaypalPaymentCallback(_onPaypalPaymentCompleted());

    // Set Stripe payment status callback.
    _state.setStripePaymentStatusCallback(_onStripePaymentStatus());

    _pageController = PageController(
      initialPage: widget.getDashboardPageIndex()!,
    );

    _pageController.addListener(
      () {
        // make sure that page has been fully scrolled
        if (_pageController.page! % 1 == 0) {
          widget.hideKeyboard();
          widget.setDashboardPageByIndex(_pageController.page!.round());
        }
      },
    );

    _state.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // #10372 - showing popup
    final sp = (_state.getShowingPopup());

    if (sp == true) {
      return scaffoldContainer(
        context,
        useSafeArea: true,
        scrollable: false,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                children: <Widget>[
                  CustomShowingPopupWidget(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // #9483 - 3rd task
    final rts = (_state.getRedirectToSubscribe());

    if (rts == true) {
      return scaffoldContainer(
        context,
        useSafeArea: true,
        scrollable: false,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                children: <Widget>[
                  CustomPaymentAccessDeniedWidget(
                    showUpgradeButton: true,
                    showLogoutButton: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return scaffoldContainer(
      context,
      useSafeArea: true,
      scrollable: false,
      body: Column(
        children: [
          DashboardMenuWidget(),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                DashboardProfileWidget(),
                DashboardMiddlewareSearchWidget(),
                DashboardConversationWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle new Video IM offer.
  OnVideoImOfferCallback _onNewVideoImOffer() {
    return (VideoImCallDataModel offer) {
      showPlatformDialog(
        context: context,
        builder: (_) => VideoImAcceptCallWidget(callData: offer),
      );
    };
  }

  /// Handle Video IM call.
  OnVideoImActiveCallCallback _onActiveVideoImCall() {
    return (VideoImCallDataModel call) async {
      final callResult = await showPlatformDialog<VideoImCallWidgetResultModel>(
        context: context,
        builder: (_) => VideoImCallWidget(callData: call),
      );

      if (callResult!.callAgain && callResult.callData != null) {
        final callData = callResult.callData!;

        final newCallData = VideoImCallDataModel(
          interlocutorId: callData.interlocutorId,
          interlocutorAvatarUrl: callData.interlocutorAvatarUrl,
          interlocutorDisplayName: callData.interlocutorDisplayName,
          role: VideoImCallRole.initiator,
          sessionId: _state.getVideoImSessionId(),
        );

        _state.videoImCallUser(newCallData);
      }
    };
  }

  /// Handle matched users.
  OnNewMatchedUserCallback _onNewMatchedUser() {
    return (DashboardMatchedUserModel user) {
      // temporally unsubscribe from matched users
      _state.setNewMatchedUserCallback(null);

      showPlatformDialog(
        context: context,
        builder: (_) => DashboardMatchedUserWidget(
          matchedUser: user,
        ),
      ).whenComplete(
        () async {
          await _state.markMatchedUserAsRead(user);

          // resubscribe to the source again
          _state.setNewMatchedUserCallback(_onNewMatchedUser());
        },
      );
    };
  }

  /// Handle Push notification.
  OnPushNotificationCallback _onPushNotification() {
    return (RemoteMessage notification) {
      final type = notification.data['type'] ?? null;

      switch (type) {
        case PushNotificationType.matchedUser:
          _handleMatchedUserNotification(notification.data);
          break;

        case PushNotificationType.message:
          _handleMessageNotification(notification.data);
          break;
      }
    };
  }

  /// Handle matched user push notification.
  void _handleMatchedUserNotification(dynamic data) {
    widget.navigateDashboardToConversationPage();
  }

  /// Handle new chat message push notification.
  void _handleMessageNotification(dynamic data) {
    final userId = data['senderId'] ?? null;

    // ignore invalid sender IDs.
    if (userId == null) {
      return;
    }

    Navigator.pushNamed(
      context,
      widget.processUrlArguments(
        MESSAGES_MAIN_URL,
        ['userId'],
        [userId],
      ),
    );
  }

  OnDashboardPageNavigatedCallback _onDashboardPageNavigated() {
    return (int? pageIndex) {
      _pageController.jumpToPage(pageIndex!);
    };
  }

  /// Handle native purchase completion.
  PaymentNativePurchaseCompletedCallback _onNativePurchaseCompleted() {
    return (PurchaseDetails purchase, bool isPurchaseValid, bool isRenewal) {
      // Update widgets and display the completion message only if the purchase
      // is valid.
      if (isPurchaseValid) {
        _state.updatePaymentWidgets();

        widget.showMessage(
          isRenewal
              ? 'payment_membership_plan_renewed_successfully'
              : 'payment_native_purchase_completed',
          context,
        );
      }

      _state.markPendingNativePurchaseAsCompleted();
    };
  }

  /// Handle pending native purchases.
  PaymentNativePurchaseCallback _onNativePurchasePending() {
    return (PurchaseDetails _) {
      // iOS marks any purchase as pending by default.
      if (Platform.isAndroid) {
        _state.markPendingNativePurchaseAsCompleted();
        widget.showMessage('payment_native_purchase_pending', context);
      }
    };
  }

  /// Handle native purchase validation error.
  PaymentNativePurchaseValidationResultCallback
      _onNativePurchaseInvalidCallback() {
    return (PurchaseDetails _, bool isRenewal) {
      _state.markPendingNativePurchaseAsCompleted();

      widget.showMessage(
        isRenewal
            ? 'payment_membership_plan_renewal_failure'
            : 'payment_native_purchase_validation_error',
        context,
      );
    };
  }

  /// Handle native purchase error.
  PaymentNativePurchaseCallback _onNativePurchaseErrorCallback() {
    return (PurchaseDetails purchase) {
      _state.markPendingNativePurchaseAsCompleted();

      // Error message to display.
      var message = 'payment_native_purchase_generic_error';

      // If the user cancelled the purchase themselves, there is no need to
      // display an error message.
      if (PaymentNativePurchaseErrorHelperUtility.isCancelledByUser(purchase)) {
        return;
      } else if (PaymentNativePurchaseErrorHelperUtility.isCancelledByBilling(
        purchase,
      )) {
        message = 'payment_native_purchase_cancelled_by_billing_error';
      } else if (PaymentNativePurchaseErrorHelperUtility
          .isAppleTermsAndConditionsChanged(purchase)) {
        message = 'payment_native_purchase_accept_apple_terms';
      }

      widget.showMessage(message, context);
    };
  }

  /// Handle native purchase plugin exception.
  PaymentNativePurchaseExceptionCallback _onNativePurchaseExceptionCallback() {
    return (Exception e) {
      var key = '';

      if (e is PlatformException &&
          e.code == PaymentInAppPurchaseError.itunesDuplicateProduct) {
        key = 'payment_native_error_itunes_duplicate_product';
      } else {
        key = 'payment_native_error_generic';
      }

      widget.showAlert(context, key);
      _state.markPendingNativePurchaseAsCompleted();
    };
  }

  /// PayPal payment completion/cancellation callback.
  Function _onPaypalPaymentCompleted() {
    return (bool completedSuccessfully) {
      widget.showMessage(
        completedSuccessfully
            ? 'payment_order_processing'
            : 'payment_order_cancelled',
        context,
      );
    };
  }

  /// Stripe payment status callback.
  Function _onStripePaymentStatus() {
    return (String status) {
      var statusKey = '';

      switch (status) {
        case 'success':
          statusKey = 'payment_order_completed_successfully';
          break;

        case 'cancel':
          statusKey = 'payment_order_cancelled';
          break;

        case 'failure':
          statusKey = 'payment_order_failed';
          break;
      }

      widget.showMessage(statusKey, context);
    };
  }
}
