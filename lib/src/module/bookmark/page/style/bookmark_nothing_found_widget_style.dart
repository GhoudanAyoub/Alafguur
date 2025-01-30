import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final bookmarkNothingFoundWidgetWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);
