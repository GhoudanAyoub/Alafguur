
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final videoImCallWidgetWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).backgroundColor(
        AppSettingsService.themeCommonVideoImCallWidgetWrapperBackgroundColor);

final videoImCallWidgetNoAnswerTextContainer = (
  String? message,
) =>
    Text(
      message!,
    )
        .fontSize(20)
        .textColor(
          AppSettingsService.themeCommonVideoImCallWidgetNoAnswerTextColor,
        )
        .padding(
          top: 24,
        );

final videoImCallWidgetTimeTextContainer = (
  String message,
) =>
    Text(
      message,
    )
        .fontSize(20)
        .textColor(AppSettingsService.themeCommonHardcodedWhiteColor)
        .padding(
          top: 24,
        );

final videoImCallWidgetCallTimerContainer = (
  String time, {
  String? paidCallInfo,
}) =>
    Column(
      children: [
        // Total call time.
        Text(time)
            .fontSize(13)
            .textColor(AppSettingsService.themeCommonHardcodedWhiteColor)
            .padding(
              bottom: 8,
            ),

        // Paid call information, if available.
        if (paidCallInfo != null)
          Text(paidCallInfo)
              .fontSize(13)
              .textColor(AppSettingsService.themeCommonHardcodedWhiteColor)
              .padding(
                horizontal: 10,
              ),
      ],
    ).padding(
      top: 20,
      bottom: 14,
    );

final videoImCallWidgetLocalVideoContainer = (
  BuildContext context,
  Widget child,
) =>
    SizedBox(
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.width * 0.36,
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        child: child,
      ),
    ).boxShadow(
      blurRadius: 14,
      color: AppSettingsService
          .themeCommonVideoImCallWidgetLocalVideoShadowColor
          .withOpacity(0.5),
    );

final videoImCallWidgetEmptyRemoteVideoContainer = () => Styled.widget(
      child: Container(),
    ).backgroundColor(
        AppSettingsService.themeCommonVideoImCallWidgetWrapperBackgroundColor);

final videoImCallWidgetLocalVideoWrapperContainer = (
  Widget child,
  BuildContext context,
  bool isVisible,
  Duration duration,
) =>
    AnimatedPositionedDirectional(
      duration: duration,
      bottom: isVisible
          ? MediaQuery.of(context).size.width * 0.43
          : MediaQuery.of(context).size.width * 0.23,
      end: 16,
      child: child,
    );

final videoImCallWidgetControlPaneWrapperContainer = (
  List<Widget> children,
  BuildContext context,
  bool isVisible,
  Duration duration,
) =>
    Positioned(
      width: MediaQuery.of(context).size.width,
      bottom: 16,
      child: Align(
        alignment: Alignment.center,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: duration,
          child: Column(
            children: children,
          ),
        ),
      ),
    );

final videoImCallWidgetFadingTextWrapperContainer = (
  Widget child,
  BuildContext context,
  bool isVisible,
  Duration duration,
) =>
    Positioned(
      width: MediaQuery.of(context).size.width,
      top: 12,
      child: Align(
        alignment: Alignment.center,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: duration,
          child: child,
        ),
      ),
    );
