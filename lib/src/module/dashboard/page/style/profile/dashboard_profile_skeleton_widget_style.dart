import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/widget/skeleton/circle_skeleton_element_widget.dart';

final dashboardProfileSkeletonWidgetWrapperContainer =
    (Widget child) => Styled.widget(
          child: child,
        )
            .padding(
              all: 16,
            )
            .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final dashboardProfileSkeletonWidgetAvatarContainer = (
  BuildContext context,
) =>
    Positioned(
      top: 0,
      child: SizedBox(
        height: 136,
        width: 136,
        child: CircleSkeletonElementWidget(),
      ).alignment(Alignment.center),
    );
