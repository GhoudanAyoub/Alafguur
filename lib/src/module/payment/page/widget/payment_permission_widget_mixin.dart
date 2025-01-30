import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../state/payment_state.dart';

mixin PaymentPermissionWidgetMixin on ModalWidgetMixin, NavigationWidgetMixin {
  void showAccessDeniedAlert(BuildContext context) {
    // show a confirmation with a possibility to go to the payment page
    if (isPaymentsAvailable) {
      showConfirmation(
        context,
        'permission_denied_alert_message',
        () => redirectToPaymentPage(context),
        title: 'permission_denied_alert_title',
        yesLabel: 'purchase',
        noLabel: 'cancel',
      );

      return;
    }

    // show a basic alert
    showAlert(context, 'permission_denied_alert_title');
  }

  /// Are payments available.
  bool get isPaymentsAvailable =>
      GetIt.instance.get<PaymentState>().isPaymentsAvailable;
}
