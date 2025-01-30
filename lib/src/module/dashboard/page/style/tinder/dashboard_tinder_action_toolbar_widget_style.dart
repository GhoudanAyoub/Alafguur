import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';

final dashboardTinderActionToolbarWidgetWrapperContainer = (
  List<Widget> children,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    ).padding(
      bottom: 10,
      horizontal: 16,
    );

final dashboardTinderActionToolbarWidgetSmallIconContainer = (
  IconData icon,
  Color iconBackgroundColor,
  Color iconColor,
  Color iconBorderColor,
  Function clickCallback, {
  double iconSize = 15,
  double iconPaddingTop = 0.0,
}) =>
    Styled.widget(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: iconBorderColor,
          ),
          color: iconBackgroundColor,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ).padding(
          top: iconPaddingTop,
        ),
      ),
    ).gestures(
      onTap: () => clickCallback(),
    );

final dashboardTinderActionToolbarWidgetShowIconContainer = (
  Function clickCallback,
) =>
    dashboardTinderActionToolbarWidgetSmallIconContainer(
      SkMobileFont.theme_5_down,
      AppSettingsService
          .themeCustomDashboardTinderActionToolbarWidgetSmallIconBackgroundColor,
      AppSettingsService
          .themeCommonDashboardTinderActionToolbarWidgetSmallIconColor,
      AppSettingsService
          .themeCommonDashboardTinderActionToolbarWidgetSmallIconColor,
      clickCallback,
      iconSize: 14,
      iconPaddingTop: 2,
    );

final dashboardTinderActionToolbarWidgetHideIconContainer = (
  Function clickCallback,
) =>
    dashboardTinderActionToolbarWidgetSmallIconContainer(
      SkMobileFont.theme_5_up,
      AppSettingsService
          .themeCustomDashboardTinderActionToolbarWidgetSmallIconBackgroundColor,
      AppSettingsService
          .themeCommonDashboardTinderActionToolbarWidgetSmallIconColor,
      AppSettingsService
          .themeCommonDashboardTinderActionToolbarWidgetSmallIconColor,
      clickCallback,
      iconSize: 14,
    );

final dashboardTinderActionToolbarWidgetProfileIconContainer = (
  Function clickCallback,
) =>
    dashboardTinderActionToolbarWidgetSmallIconContainer(
      SkMobileFont.theme_5_dashboard,
      AppSettingsService
          .themeCustomDashboardTinderActionToolbarWidgetSmallIconBackgroundColor,
      AppSettingsService
          .themeCommonDashboardTinderActionToolbarWidgetSmallIconColor,
      AppSettingsService
          .themeCommonDashboardTinderActionToolbarWidgetSmallIconColor,
      clickCallback,
      iconSize: 17,
    );

final dashboardTinderActionToolbarWidgetBigIconContainer = (
  IconData icon,
  Color backgroundColor,
  Color iconColor,
  double sizeIcon,
  Function clickCallback, {
  double iconPaddingTop = 0,
  double iconPaddingBottom = 0,
}) =>
    Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Icon(
        icon,
        size: sizeIcon,
        color: iconColor,
      ).padding(
        top: iconPaddingTop,
        bottom: iconPaddingBottom,
      ),
    ).gestures(
      onTap: () => clickCallback(),
    );

final dashboardTinderActionToolbarWidgetDislikeIconContainer = (
  Function clickCallback,
) =>
    dashboardTinderActionToolbarWidgetBigIconContainer(
      SkMobileFont.theme_dislike,
      AppSettingsService
          .themeCustomDashboardTinderActionToolbarDislikeIconBackgroundColor,
      AppSettingsService
          .themeCustomDashboardTinderActionToolbarDislikeIconColor,
      25,
      clickCallback,
      iconPaddingTop: 3,
    );

final dashboardTinderActionToolbarWidgetLikeIconContainer = (
  Function clickCallback,
) =>
    dashboardTinderActionToolbarWidgetBigIconContainer(
      SkMobileFont.ic_like,
      AppSettingsService.themeCommonProfileActionToolbarLikeIconBackgroundColor,
      AppSettingsService.themeCommonIconLightColor,
      25,
      clickCallback,
      iconPaddingTop: 3,
    );

final dashboardTinderActionToolbarWidgetRewindIconContainer = (
  bool isActive,
  Function clickCallback,
) =>
    Opacity(
      opacity: isActive ? 1 : 0.5,
      child: dashboardTinderActionToolbarWidgetBigIconContainer(
        SkMobileFont.ic_rewind,
        AppSettingsService
            .themeCommonDashboardTinderActionToolbarWidgetRewindIconBackgroundColor,
        AppSettingsService.themeCommonIconLightColor,
        22,
        () => isActive ? clickCallback() : null,
      ),
    );
