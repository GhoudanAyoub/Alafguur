import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

final messageChatSkeletonWidgetWrapperContainer =
    (Widget child) => Styled.widget(child: child)
        .padding(
          horizontal: 11,
          vertical: 11,
        )
        .width(double.infinity)
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);
