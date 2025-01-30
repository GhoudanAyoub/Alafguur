import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';

final dashboardHotListWidgetEmptyIconContainer = () => Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppSettingsService.themeCommonGradientStartColor,
            AppSettingsService.themeCommonGradientEndColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        SkMobileFont.theme_5_hotlist,
        color: AppSettingsService.themeCommonIconLightColor,
        size: 67,
      ),
    );

final dashboardHotListWidgetEmptyTextContainer = (
  String? message,
) =>
    Text(
      message!,
      style: TextStyle(
        color: AppSettingsService.themeCommonHotListEmptyTextColor,
        fontSize: 20,
      ),
    ).padding(
      top: 11,
    );
