import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';

final dashboardConversationWidgetWrapperContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final dashboardConversationWidgetSearchBarContainer =
    (Widget widget) => widget.height(40).padding(
          bottom: 20,
          horizontal: 16,
        );

final dashboardConversationWidgetHeaderContainer = (
  String? header, {
  double paddingHorizontal = 16,
}) =>
    Text(header!)
        .textColor(AppSettingsService.themeCommonFormSectionColor)
        .fontSize(13)
        .fontWeight(FontWeight.w500)
        .padding(
          bottom: 16,
          horizontal: paddingHorizontal,
        );

Widget dashboardConversationWidgetNotificationContainer(
  BuildContext context,
) {
  bool isRtlModeActive = isRtlMode(context);
  return Positioned(
    top: 5,
    right: !isRtlModeActive ? 3 : null,
    left: isRtlModeActive ? 3 : null,
    child: Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppSettingsService.themeCommonScaffoldLightColor,
        shape: BoxShape.circle,
      ),
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppSettingsService.themeCustomNotificationBackgroundColor,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}
