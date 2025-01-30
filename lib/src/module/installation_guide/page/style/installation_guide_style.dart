import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final installationGuideWrapperContainer = (
  BuildContext context,
  Widget child,
) =>
    child.padding(
      horizontal: MediaQuery.of(context).size.width * 0.16,
      vertical: 25,
    );

final installationGuideTitleContainer = (
  String? title,
) =>
    Text(title!.toUpperCase())
        .fontSize(17)
        .fontWeight(FontWeight.w600)
        .textColor(AppSettingsService.themeCommonAccentColor)
        .textAlignment(TextAlign.center)
        .padding(
          bottom: 16,
        );

final installationGuideDescrContainer = (
  String? title,
) =>
    Text(title!)
        .fontSize(16)
        .textColor(AppSettingsService.themeCommonTextColor)
        .textAlignment(TextAlign.center);

final installationGuideImageContainer = (
  Widget child,
) =>
    child.padding(
      top: 16,
      bottom: 32,
    );
