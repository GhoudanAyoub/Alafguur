import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';

final paymentAccessDeniedWidgetImageContainer = () => Icon(
      SkMobileFont.ic_no_permission,
      color: AppSettingsService.themeCommonDangerousColor,
      size: 75,
    ).padding(bottom: 16);

final paymentAccessDeniedWidgetTitleContainer = (
  String? message,
) =>
    Text(
      message!,
      textAlign: TextAlign.center,
    )
        .textColor(AppSettingsService.themeCommonBlankTitleColor)
        .fontSize(20)
        .padding(
          bottom: 16,
          horizontal: 16,
        );

final paymentAccessDeniedWidgetDescrContainer = (
  String? message,
) =>
    Text(
      message!,
      textAlign: TextAlign.center,
    )
        .textColor(AppSettingsService.themeCommonBlankDescrColor)
        .fontSize(18)
        .padding(bottom: 40, horizontal: 16);

final paymentAccessDeniedWidgetButtonContainer = (
  String? message,
  Function clickCallback,
) =>
    Styled.widget(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppSettingsService.themeCommonAccentColor, minimumSize: Size(200, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64.0),
          ),
          side: BorderSide(
              width: 1, color: AppSettingsService.themeCommonAccentColor),
        ),
        child: Text(
          message!,
        ).fontSize(18),
        onPressed: () => clickCallback(),
      ).height(48).padding(horizontal: 16),
    );

final paymentAccessDeniedWidgetBackButtonContainer = (
  String? message,
  Function clickCallback,
) =>
    Styled.widget(
      child: TextButton(
        onPressed: clickCallback as void Function()?,
        child: Text(message!).fontSize(17),
        style: TextButton.styleFrom(
            foregroundColor: AppSettingsService.themeCommonAccentColor),
      ).padding(top: 12),
    );
