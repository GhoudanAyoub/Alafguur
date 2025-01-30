import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final paymentInitialSkeletonWidgetContainer = (
  List<Widget> children,
) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ).backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);
