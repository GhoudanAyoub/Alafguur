import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';

final dashboardMenuWidgetIconsContainer = (
  Widget child,
) =>
    child
        .padding(
          vertical: 10,
          horizontal: 7,
        )
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final dashboardMenuWidgetIconContainer = (
  IconData icon,
  bool isActive,
  Function clickCallback,
  Color iconActiveColor, {
  double iconSize = 21,
  double iconPaddingTopVertical = 0,
  double iconPaddingBottomVertical = 0,
  double iconPaddingHorizontal = 0,
  AlignmentDirectional iconAlignment = const AlignmentDirectional(0.0, 0.0),
}) =>
    SizedBox(
      width: 50,
      height: 36,
      child: AnimatedOpacity(
          opacity: isActive ? 1 : 1,
          duration: Duration(seconds: 1),
          child: Icon(
            icon,
            color: isActive
                ? iconActiveColor
                : AppSettingsService
                    .themeCommonDashboardMenuWidgetPassiveIconColor,
            size: iconSize,
          )
              .padding(
                top: iconPaddingTopVertical,
                bottom: iconPaddingBottomVertical,
                horizontal: iconPaddingHorizontal,
              )
              .alignment(iconAlignment)),
    )
        .backgroundColor(
          transparentColor(),
        )
        .gestures(
          onTap: () => clickCallback(),
        );

final dashboardMenuWidgetProfileIconContainer = (
  bool isActive,
  Function clickCallback,
) =>
    dashboardMenuWidgetIconContainer(
      SkMobileFont.theme_5_dashboard,
      isActive,
      clickCallback,
      AppSettingsService.themeCommonAccentColor,
      iconAlignment: AlignmentDirectional.centerStart,
      iconSize: 24,
    );

Widget dashboardMenuWidgetSearchMiddlewareAnimationContainer(
  BuildContext context,
  int subPageMenuElementOffset, {
  int animationDuration = 600,
}) =>
    AnimatedPositionedDirectional(
      start: subPageMenuElementOffset.toDouble(),
      width: 50,
      height: 36,
      duration: Duration(milliseconds: animationDuration),
      curve: Curves.fastOutSlowIn,
      child: Container(
        decoration: BoxDecoration(
          color: AppSettingsService.themeCommonAccentColor,
          borderRadius: BorderRadius.all(
            Radius.circular(21),
          ),
        ),
      ),
    );

final dashboardMenuWidgetSearchMiddlewareIconsWrapperContainer = (
  List<Widget> children,
) =>
    Stack(
      children: children,
    ).decorated(
      border: Border.all(
        width: 2,
        color: AppSettingsService.themeCommonDashboardMenuWidgetBorderColor,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(100),
      ),
    );

final dashboardMenuWidgetHotListIconContainer = (
  bool isActive,
  Function clickCallback,
) =>
    dashboardMenuWidgetIconContainer(
      SkMobileFont.theme_5_hotlist,
      isActive,
      clickCallback,
      AppSettingsService.themeCommonIconLightColor,
      iconSize: 18,
    );

final dashboardMenuWidgetTinderCardsIconContainer = (
  bool isActive,
  Function clickCallback,
) =>
    dashboardMenuWidgetIconContainer(
      SkMobileFont.theme_5_card,
      isActive,
      clickCallback,
      AppSettingsService.themeCommonIconLightColor,
      iconPaddingTopVertical: 2,
      iconSize: 18,
    );

final dashboardMenuWidgetBrowseIconContainer = (
  bool isActive,
  Function clickCallback,
) =>
    dashboardMenuWidgetIconContainer(
      SkMobileFont.theme_5_search,
      isActive,
      clickCallback,
      AppSettingsService.themeCommonIconLightColor,
      iconSize: 16,
    );

final dashboardMenuWidgetConversationIconContainer = (
  BuildContext context,
  bool isActive,
  bool isNew,
  Function clickCallback,
) =>
    Stack(
      children: [
        // an icon
        dashboardMenuWidgetIconContainer(
          SkMobileFont.theme_5_messages,
          isActive,
          clickCallback,
          AppSettingsService.themeCommonAccentColor,
          iconSize: 22,
          iconAlignment: AlignmentDirectional.centerEnd,
        ),

        // a new badge
        if (isNew)
          Positioned.directional(
              textDirection: Directionality.of(context),
              top: 5,
              end: -2,
              child: Styled.widget(
                child: SizedBox(
                  width: 8,
                  height: 8,
                )
                    .decorated(
                      color: AppSettingsService
                          .themeCustomNotificationBackgroundColor,
                      shape: BoxShape.circle,
                    )
                    .padding(
                      all: 2,
                    ),
              ).decorated(
                color: AppSettingsService.themeCommonScaffoldLightColor,
                shape: BoxShape.circle,
              ))
      ],
    );
