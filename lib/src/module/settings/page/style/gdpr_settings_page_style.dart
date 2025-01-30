import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final gdprSettingsPageTextWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).padding(
      all: 16,
    );

final gdprSettingsPageTextContainer = (
  String label,
) =>
    Text(label).textColor(
      AppSettingsService.themeCommonTextColor,
    );

final gdprSettingsPageEditButtonWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).padding(
      top: 2,
    );
