import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

final settingsPageItemContainer = (
  Widget child,
  String? label,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: infoItemLabelContainer(label),
        ),
        Icon(
          Icons.navigate_next,
          color: AppSettingsService.themeCommonSelectArrowColor,
          size: 26,
        ),
      ],
    );

final settingsPageButtonWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    )
        .padding(
          top: 10,
          bottom: 10,
        )
        .backgroundColor(AppSettingsService.themeCommonScaffoldDefaultColor);

final settingsPageButtonContainer = (
  String? label,
  Function clickCallback, {
  bool negative = false,
}) =>
    Styled.widget(
      child: TextButton(
        child: Text(
          label!,
          style: TextStyle(
            color: negative
                ? AppSettingsService.themeCommonDangerousColor
                : AppSettingsService.themeCommonAccentColor,
          ),
        ).fontSize(16).fontWeight(FontWeight.w400),
        onPressed: clickCallback as void Function()?,
      ).constrained(
        height: 48,
      ),
    )
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor)
        .width(double.infinity)
        .padding(bottom: 6);
