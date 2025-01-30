import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final settingsPageSkeletonWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    )
        .padding(top: 16)
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);
