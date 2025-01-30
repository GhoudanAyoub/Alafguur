import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';

final searchSkeletonWrapperContainer = (Widget child) =>
    Styled.widget(child: child)
        .padding(all: 16)
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);
