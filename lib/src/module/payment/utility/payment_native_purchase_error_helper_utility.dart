import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Purchase error messages to determine the error type on Android.
class _PaymentNativePurchaseAndroidErrorMessages {
  static const userCancelled = 'BillingResponse.userCanceled';
  static const billingCancelled = 'BillingResponse.error';
}

/// Purchase error codes to determine the error type on iOS.
class _PaymentNativePurchaseIosErrorCodes {
  static const cancelledByUser = 6;
  static const termsAndConditionsChanged = 3038;
}

/// Helper functions to simplify working with native purchase errors.
class PaymentNativePurchaseErrorHelperUtility {
  /// Determine whether the user has interrupted the normal [purchase] flow.
  static bool isCancelledByUser(PurchaseDetails purchase) {
    if (purchase.error == null) {
      return false;
    }

    return Platform.isAndroid
        ? _isCancelledByUserAndroid(purchase)
        : _isCancelledByUserIos(purchase);
  }

  /// Determine whether the [purchase] has been cancelled by the billing system.
  static bool isCancelledByBilling(PurchaseDetails purchase) {
    return purchase.error?.message ==
        _PaymentNativePurchaseAndroidErrorMessages.billingCancelled;
  }

  /// Determine whether the [purchase] was interrupted because the Apple's terms
  /// and conditions have changed.
  static bool isAppleTermsAndConditionsChanged(PurchaseDetails purchase) {
    if (Platform.isAndroid) {
      return false;
    }

    try {
      if (purchase.error?.details is! Map) {
        return false;
      }
      
      final details = purchase.error!.details as Map;
      if (!details.containsKey('NSUnderlyingError') || details['NSUnderlyingError'] is! Map) {
        return false;
      }
      
      final error = details['NSUnderlyingError'] as Map;
      if (!error.containsKey('code') || error['code'] is! int) {
        return false;
      }

      return (error['code'] as int) ==
          _PaymentNativePurchaseIosErrorCodes.termsAndConditionsChanged;
    } catch (_) {
      return false;
    }
  }

  /// Returns `true` if the purchase flow has been cancelled by user, works on
  /// Android only.
  static bool _isCancelledByUserAndroid(PurchaseDetails purchase) {
    return purchase.error?.message ==
        _PaymentNativePurchaseAndroidErrorMessages.userCancelled;
  }

  /// Returns `true` if the purchase flow has been cancelled by user, works on
  /// iOS only.
  static bool _isCancelledByUserIos(PurchaseDetails purchase) {
    // On iOS the `in_app_purchase` plugin does not provide a straightforward
    // way to determine whether the purchase has been cancelled by the user.
    //
    // This rather contrived parsing algorithm determines whether the user
    // has cancelled the purchase flow or it's some other kind of error.
    try {
      if (purchase.error?.details is! Map) {
        return false;
      }
      
      final errorDetails = purchase.error!.details as Map;
      if (!errorDetails.containsKey('NSUnderlyingError') || 
          errorDetails['NSUnderlyingError'] is! Map ||
          !(errorDetails['NSUnderlyingError'] as Map).containsKey('userInfo')) {
        return false;
      }
      
      final userInfoObj = errorDetails['NSUnderlyingError']['userInfo'];
      if (userInfoObj == null || userInfoObj is! Map) {
        return false;
      }
      
      final userInfo = userInfoObj as Map;
      if (!userInfo.containsKey('NSUnderlyingError') || 
          userInfo['NSUnderlyingError'] is! Map ||
          !(userInfo['NSUnderlyingError'] as Map).containsKey('code') ||
          (userInfo['NSUnderlyingError'] as Map)['code'] is! int) {
        return false;
      }
      
      final errorCode = userInfo['NSUnderlyingError']['code'] as int;

      return errorCode == _PaymentNativePurchaseIosErrorCodes.cancelledByUser;
    } catch (_) {
      return false;
    }
  }
}
