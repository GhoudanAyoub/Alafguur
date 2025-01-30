import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/loading_spinner_widget.dart';

/// Billing gateway container. Displays the gateway image in a square box.
Widget paymentBillingGatewayContainer(
  BuildContext context,
  String name,
  bool isLoading,
  bool isDisabled, {
  Function? onTapCallback,
}) {
  return GestureDetector(
    child: Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 22,
          child: Container(
            alignment: Alignment.center,
            child:
                // Billing gateway logo.
                Image.asset(
              'assets/image/payment/billing_gateways/$name.png',
              width: 120,
              alignment: Alignment.center,
            ),
          )
              .constrained(
                height: 150,
              )
              .decorated(
                color: AppSettingsService.themeCommonScaffoldLightColor,
                border: Border.all(
                  color: AppSettingsService
                      .themeCommonPaymentBillingGatewayBorderColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
        ),
        // Loading spinner.
        if (isLoading)
          Positioned.fill(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 22,
              height: 150,
              child: LoadingSpinnerWidget(),
            ).decorated(
              color: isLoading
                  ? AppSettingsService.themeCommonScaffoldLightColor
                      .withOpacity(0.6)
                  : transparentColor(),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
      ],
    ),
    onTap: onTapCallback as void Function()?,
  );
}

final paymentBillingGatewayListContainer = (
  List<Widget> children,
) =>
    Styled.widget(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: children,
      ),
    ).alignment(Alignment.topCenter).padding(
          vertical: 16,
        );
