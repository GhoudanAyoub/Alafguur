import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/image_loader_widget.dart';

final joinInitialAvatarWidgetTextContainer = (
  String? message,
) =>
    Text(
      message!,
      style: TextStyle(color: AppSettingsService.themeCommonAccentColor),
    ).fontSize(18).padding(top: 30);

final joinInitialAvatarWidgetImageContainer = (
  Widget child,
) =>
    Styled.widget(child: child)
        .decorated(
          border: Border.all(
            color: AppSettingsService.themeCommonAccentColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        )
        .width(180)
        .height(180)
        .padding(vertical: 40, horizontal: 12);

final joinInitialAvatarWidgetPreviewImageContainer = (
  String? url,
) =>
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ImageLoaderWidget(
        imageUrl: url,
        width: 180,
        height: 180,
      ),
    );

final joinInitialAvatarWidgetIconContainer = () => Styled.widget(
      child: Icon(
        Icons.add,
        color: AppSettingsService.themeCommonAccentColor,
        size: 50,
      ),
    );

final joinInitialAvatarWidgetDeleteIconContainer = (
  BuildContext context,
  Function clickCallback,
) =>
    Positioned.directional(
      textDirection: isRtlMode(context) ? TextDirection.rtl : TextDirection.ltr,
      top: 28,
      end: 0,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppSettingsService.themeCommonWarningColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          size: 22,
          color: AppSettingsService.themeCommonIconLightColor,
        ),
      ).gestures(
        onTap: () => clickCallback(),
      ),
    );
