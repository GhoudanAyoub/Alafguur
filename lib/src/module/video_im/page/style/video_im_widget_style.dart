import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../animation/video_im_call_widget_ripples_animation.dart';

final videoImWidgetBlurBackroundWrapperContainer = (
  Widget child,
  String imageUrl,
) =>
    Styled.widget(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Styled.widget(
          child: child,
        )
            .padding(
              horizontal: 16,
              top: 16,
              bottom: 30,
            )
            .backgroundColor(
              AppSettingsService
                  .themeCommonVideoImWidgetBlurOverlayBackgroundColor
                  .withOpacity(0.83),
            ),
      ),
    )
        .decorated(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        )
        .alignment(Alignment.center);

final videoImWidgetActionTextContainer = (
  String? message,
  bool isCallReady,
) =>
    Text(
      message!,
    )
        .textColor(
          !isCallReady
              ? AppSettingsService.themeCommonHardcodedWhiteColor
                  .withOpacity(0.4)
              : AppSettingsService.themeCommonHardcodedWhiteColor,
        )
        .fontSize(16)
        .padding(
          top: 20,
        );

final videoImWidgetNameTextContainer = (
  String message,
) =>
    Text(
      message,
    )
        .textColor(
          AppSettingsService.themeCommonHardcodedWhiteColor,
        )
        .fontSize(24)
        .padding(
          top: 7,
          bottom: 10,
        );

final videoImWidgetContWrapperContainer = (
  List<Widget> children,
) =>
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

final videoImWidgetButtonsWrapperContainer = (
  List<Widget> children,
) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

final videoImWidgetAvatarContainer = (
  String imageUrl,
) =>
    SizedBox(
      width: 190,
      height: 190,
      child: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
    ).alignment(
      Alignment.center,
    );

final videoImWidgetRipplesAnimationAvatarContainer = (
  String imageUrl,
  AnimationController controller,
) =>
    CustomPaint(
      painter: VideoImCallWidgetRipplesAnimation(
        controller,
        ripplesColor: AppSettingsService.themeCommonIconLightColor,
      ),
      child: videoImWidgetAvatarContainer(imageUrl),
    );

final videoImWidgetIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
  Color buttonColor,
  Color borderColor,
  IconData icon,
  Color iconColor,
) =>
    Tooltip(
      message: message!,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.square(65), backgroundColor: buttonColor,
          elevation: 0,
          shape: CircleBorder(),
          side: BorderSide(
            color: borderColor,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 35,
        ),
        onPressed: clickCallback as void Function()?,
      ).padding(
        horizontal: MediaQuery.of(context).size.width * 0.01,
      ),
    );

final videoImWidgetCallIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      AppSettingsService.themeCommonVideoImWidgetCallPhoneIconColor,
      AppSettingsService.themeCommonVideoImWidgetCallPhoneIconColor,
      CupertinoIcons.phone_fill,
      AppSettingsService.themeCommonIconLightColor,
    );

final videoImWidgetMuteCallIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
  bool isLocalAudioEnabled,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      transparentColor(),
      isLocalAudioEnabled
          ? AppSettingsService.themeCommonIconLightColor.withOpacity(0.4)
          : AppSettingsService.themeCommonIconLightColor,
      isLocalAudioEnabled
          ? CupertinoIcons.mic_fill
          : CupertinoIcons.mic_slash_fill,
      isLocalAudioEnabled
          ? AppSettingsService.themeCommonIconLightColor.withOpacity(0.4)
          : AppSettingsService.themeCommonIconLightColor,
    );

final videoImWidgetEndCallIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      AppSettingsService.themeCommonVideoImWidgetEndCallPhoneIconColor,
      AppSettingsService.themeCommonVideoImWidgetEndCallPhoneIconColor,
      CupertinoIcons.phone_down_fill,
      AppSettingsService.themeCommonIconLightColor,
    );

final videoImWidgetCloseCallIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      transparentColor(),
      AppSettingsService.themeCommonIconLightColor.withOpacity(0.4),
      CupertinoIcons.xmark,
      AppSettingsService.themeCommonIconLightColor.withOpacity(0.4),
    );

final videoImWidgetBlockUserIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      transparentColor(),
      AppSettingsService.themeCommonIconLightColor.withOpacity(0.4),
      Icons.block_rounded,
      AppSettingsService.themeCommonIconLightColor.withOpacity(0.4),
    );

final videoImWidgetVideoIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
  bool isLocalVideoEnabled,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      transparentColor(),
      isLocalVideoEnabled
          ? AppSettingsService.themeCommonIconLightColor.withOpacity(0.4)
          : AppSettingsService.themeCommonIconLightColor,
      isLocalVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
      isLocalVideoEnabled
          ? AppSettingsService.themeCommonIconLightColor.withOpacity(0.4)
          : AppSettingsService.themeCommonIconLightColor,
    );

final videoImWidgetRingtoneIconContainer = (
  BuildContext context,
  String? message,
  Function clickCallback,
  bool isRingtoneEnabled,
) =>
    videoImWidgetIconContainer(
      context,
      message,
      clickCallback,
      transparentColor(),
      isRingtoneEnabled
          ? AppSettingsService.themeCommonIconLightColor.withOpacity(0.4)
          : AppSettingsService.themeCommonIconLightColor,
      isRingtoneEnabled
          ? CupertinoIcons.bell_fill
          : CupertinoIcons.bell_slash_fill,
      isRingtoneEnabled
          ? AppSettingsService.themeCommonIconLightColor.withOpacity(0.4)
          : AppSettingsService.themeCommonIconLightColor,
    );
