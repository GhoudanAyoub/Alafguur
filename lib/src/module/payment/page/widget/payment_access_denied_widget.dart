import 'package:flutter/material.dart';

import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../style/payment_access_denied_widget_style.dart';
import 'payment_permission_widget_mixin.dart';

class PaymentAccessDeniedWidget extends StatelessWidget
    with ModalWidgetMixin, NavigationWidgetMixin, PaymentPermissionWidgetMixin {
  final bool showBackButton;
  final bool showUpgradeButton;

  const PaymentAccessDeniedWidget({
    Key? key,
    this.showBackButton = false,
    this.showUpgradeButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // an icon
        paymentAccessDeniedWidgetImageContainer(),
        // a title
        paymentAccessDeniedWidgetTitleContainer(
          LocalizationService.of(context).t('permission_denied_header'),
        ),
        if (isPaymentsAvailable) ...[
          if (showUpgradeButton) ...[
            // a description
            paymentAccessDeniedWidgetDescrContainer(
              LocalizationService.of(context).t(
                'permission_denied_alert_message',
              ),
            ),

            // an upgrade button
            paymentAccessDeniedWidgetButtonContainer(
              LocalizationService.of(context).t('upgrade'),
              () => showAccessDeniedAlert(context),
            ),
          ],
          // a back button
          if (showBackButton)
            paymentAccessDeniedWidgetBackButtonContainer(
              LocalizationService.of(context).t('back'),
              () => _back(context),
            )
        ]
      ],
    );
  }

  void _back(BuildContext context) {
    Navigator.pop(context);
  }
}
