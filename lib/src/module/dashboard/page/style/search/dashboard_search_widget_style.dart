import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';

final dashboardSearchWidgetWrapperContainer = (Widget child) => Styled.widget(
      child: child,
    )
        .padding(
          horizontal: 16,
          bottom: 16,
        )
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final dashboardSearchBarWrapperContainer = (Widget child) => Styled.widget(
      child: child,
    ).padding(bottom: 10);

final dashboardSearchBarContainer = (Widget widget) => widget.height(40);

final dashboardSearchLabelContainer = (
  String? message,
) =>
    Text(
      message!.toUpperCase(),
    ).fontSize(16).textColor(AppSettingsService.themeCommonAccentColor);

final dashboardSearchFilterIconContainer = (
  Function clickCallback,
  bool isRtl,
  bool isSearchByUserNameAllowed,
) =>
    isSearchByUserNameAllowed
        ? SizedBox(
            width: 28,
            child: IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () => clickCallback(),
              icon: Icon(
                SkMobileFont.ic_search_filter,
                size: 28,
                color: AppSettingsService.themeCommonAccentColor,
              ),
            ),
          ).padding(
            left: !isRtl ? 20 : 0,
            right: isRtl ? 20 : 0,
          )
        : SizedBox(
            width: 28,
            child: IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () => clickCallback(),
              icon: Icon(
                SkMobileFont.ic_search_filter,
                size: 28,
                color: AppSettingsService.themeCommonAccentColor,
              ),
            ),
          ).padding(
            right: !isRtl ? 16 : 0,
            left: isRtl ? 16 : 0,
          );
