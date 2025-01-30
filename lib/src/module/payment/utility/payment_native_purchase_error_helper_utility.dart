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
      final details = (purchase.error?.details as Map);
      final error = (details['NSUnderlyingError'] as Map);

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
      final errorDetails = (purchase.error?.details as Map);
      final userInfo = (errorDetails['NSUnderlyingError']['userInfo']! as Map);
      final errorCode = (userInfo['NSUnderlyingError']['code'] as int);

      return errorCode == _PaymentNativePurchaseIosErrorCodes.cancelledByUser;
    } catch (_) {
      return false;
    }
  }
}
