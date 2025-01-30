import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';

final dashboardConversationSkeletonWidgetWrapperContainer = (Widget child) =>
    Styled.widget(child: child)
        .padding(top: 16)
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);
