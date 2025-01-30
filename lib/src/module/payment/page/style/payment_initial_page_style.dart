import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

/// Builds a product item with the given [title]. Use [outerPadding] to set
/// padding between the items.
Widget paymentInitialPageProductItemContainer(
  BuildContext context, {
  required String title,
  double outerPadding = 20,
  Function? onTapCallback,
}) {
  return infoItemContainer(
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Product title widget.
        Expanded(
          child: infoItemLabelContainer(title),
        ),

        // Forward arrow icon.
        Icon(
          Icons.navigate_next,
          color: AppSettingsService.themeCommonSelectArrowColor,
          size: 26.0,
        )
      ],
    ),
    context,
    displayBorder: false,
    backgroundColor: true,
    clickCallback: onTapCallback,
    innerPaddingVertical: 19,
  ).padding(bottom: outerPadding);
}

/// Builds an info item with the given [label] and a theme-specific forward
/// arrow icon to the far right of it.
Widget paymentInitialPageInfoItemLinkContainer({required String? label}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: infoItemLabelContainer(label),
      ),
      Icon(
        Icons.navigate_next,
        color: AppSettingsService.themeCommonSelectArrowColor,
        size: 26.0,
      ),
    ],
  );
}

final paymentInitialEmptyWidgetWrapperContainer = (
  BuildContext context,
  Widget child,
) =>
    SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: child,
          ).alignment(Alignment.center),
        ],
      ),
    );

Widget paymentInitialActionWrapperContainer(
  String message,
  BuildContext context,
) {
  bool isRtlModeActive = isRtlMode(context);
  return Row(
    children: [
      Expanded(
        child: infoItemLabelContainer(message),
      ),
    ],
  ).padding(
    right: !isRtlModeActive ? 10 : 0,
    left: isRtlModeActive ? 10 : 0,
  );
}

final paymentInitialActionListWraperContainer = (
  List<Widget> children,
) =>
    Column(
      children: children,
    ).padding(
      bottom: 16,
    );

final paymentInitialMembershipWidgetUserInfoWrapperContainer = (
  String title,
  Widget child,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Text(title)
                  .textColor(AppSettingsService.themeCommonTextColor)
                  .fontSize(15),
              Text(':')
                  .textColor(AppSettingsService.themeCommonTextColor)
                  .fontSize(15),
            ],
          ),
        ),
        child,
      ],
    ).padding(
      horizontal: 16,
      bottom: 18,
      top: 16,
    );

final paymentInitialMembershipWidgetUserInfoContainer = (
  String title,
  Function clickCallBack, {
  Color? infoColor,
}) =>
    Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title.toUpperCase(),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )
                .fontSize(15)
                .textColor(
                  infoColor!,
                )
                .padding(
                  horizontal: 3,
                ),
          ),
          Icon(
            Icons.info_outlined,
            size: 22,
            color: infoColor,
            // AppSettingsService.themeCommonAccentColor,
          ),
        ],
      ).gestures(
        onTap: () => clickCallBack(),
      ),
    );
