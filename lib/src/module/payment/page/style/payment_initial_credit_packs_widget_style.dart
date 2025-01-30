import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

final paymentInitialCreditPacksWidgetListWrapperContainer = (
  List<Widget> children,
) =>
    Column(
      children: children,
    ).padding(
      horizontal: 16,
      top: 6,
    );

/// Builds a product item with the given [title] and the [price] to the far
/// right side of it. Use [outerPadding] to set padding between the items.
Widget paymentInitialPagePricedProductItemContainer(
  BuildContext context,
  String pack,
  String title,
  String price, {
  double outerPadding = 20,
  Function? onTapCallback,
}) {
  return infoItemContainer(
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Product title widget.
        Row(
          children: <Widget>[
            // Amount of credits in the pack.
            Text(pack)
                .textColor(AppSettingsService.themeCommonTextColor)
                .fontSize(15),

            // "Credits" string.
            Text(title)
                .textColor(AppSettingsService.themeCommonTextColor)
                .fontSize(15)
                .padding(
                  horizontal: 4,
                ),
          ],
        ),

        // Product price.
        Text(price)
            .textColor(AppSettingsService.themeCommonTextColor)
            .fontSize(15)
            .textColor(
                AppSettingsService.themeCommonPaymentInitialHighlightColor)
            .padding(horizontal: 16),
      ],
    ),
    context,
    displayBorder: false,
    backgroundColor: true,
    clickCallback: onTapCallback,
    innerPaddingVertical: 19,
  ).padding(bottom: outerPadding);
}
