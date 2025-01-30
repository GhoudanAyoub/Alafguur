import 'package:flutter/cupertino.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

Widget joinFinalizePageTosContainer(
  Widget child,
  BuildContext context,
) {
  bool isRtlModeActive = isRtlMode(context);
  return Styled.widget(child: child)
      .padding(
        left: !isRtlModeActive ? 16 : 0,
        right: isRtlModeActive ? 16 : 0,
      )
      .backgroundColor(
        AppSettingsService.themeCommonScaffoldLightColor,
      );
}

final joinFinalizePageTosLinkTextContainer = (
  String label,
) =>
    Text(label).fontSize(17).padding(
          vertical: 15,
        );

final joinFinalizePageTosPopupTextContainer = (
  Widget child,
) =>
    Styled.widget(child: child).padding(all: 20).backgroundColor(
          AppSettingsService.themeCommonScaffoldLightColor,
        );
