import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../service/model/payment_membership_model.dart';

/// Payment membership plan container.
///
/// Displays an [infoItemContainer] with the given [description] on the left and
/// optional [recurringText] and forward navigation arrow on the right.
///
/// The provided [onTapCallback] is triggered when user taps the container.
Widget paymentMembershipInfoWidgetMembershipPlanContainer(
  BuildContext context,
  String price,
  String billingPeriod, {
  bool isTrial = false,
  String? recurringText,
  Function? onTapCallback,
}) {
  return infoItemContainer(
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Left side, plan description.
        Flexible(
          child: Row(
            children: <Widget>[
              // Plan price with currency, e.g. "USD 10."
              Flexible(
                child: Text(price).fontSize(15).textColor(
                    AppSettingsService.themeCommonPaymentInitialHighlightColor),
              ),

              // Plan billing period, e.g. "per 1 month."
              Flexible(
                child: Text(billingPeriod)
                    .textColor(AppSettingsService.themeCommonTextColor)
                    .padding(
                      horizontal: 4,
                    ),
              ),
            ],
          ),
        ),

        // Right side, optional "recurring" text and forward arrow.
        Row(
          children: <Widget>[
            // Optional "recurring" text.
            if (recurringText?.length != 0)
              Text(recurringText!)
                  .fontSize(15)
                  .textColor(AppSettingsService.themeCommonSelectArrowColor)
                  .padding(
                    bottom: 2,
                  ),

            // Right arrow icon.
            Icon(
              Icons.navigate_next,
              color: AppSettingsService.themeCommonSelectArrowColor,
              size: 26.0,
            ),
          ],
        ),
      ],
    ),
    context,
    displayBorder: false,
    backgroundColor: true,
    clickCallback: onTapCallback,
  )
      .constrained(
        width: MediaQuery.of(context).size.width - 32,
      )
      .padding(
        horizontal: 16,
        top: 16,
        bottom: 4,
      );
}

final paymentMembershipInfoWidgetExpiringInfoWrapperContainer = (
  PaymentMembershipModel membership,
  String expiringTitle,
  BuildContext context,
) =>
    SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: Text(membership.title)
                      .textColor(AppSettingsService.themeCommonTextColor)
                      .fontSize(15),
                ),
                Text(':')
                    .textColor(AppSettingsService.themeCommonTextColor)
                    .fontSize(15),
              ],
            ),
          ),
          if (membership.expire != null)
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(expiringTitle)
                      .textColor(AppSettingsService.themeCommonAccentColor)
                      .padding(
                        horizontal: 3,
                      ),
                  Flexible(
                    child: Text(membership.expire!)
                        .textColor(AppSettingsService.themeCommonAccentColor),
                  ),
                ],
              ),
            )
        ],
      ),
    ).padding(
      top: 16,
      bottom: 8,
      horizontal: 16,
    );
