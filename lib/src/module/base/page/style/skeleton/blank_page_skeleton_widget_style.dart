import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../widget/skeleton/circle_skeleton_element_widget.dart';

final Widget Function(
  Widget, {
  double paddingBottom,
  double paddingLeft,
  double paddingRight,
  double paddingTop,
}) blankPageSkeletonContainer = (
  Widget child, {
  double? paddingTop,
  double? paddingBottom,
  double? paddingLeft,
  double? paddingRight,
}) =>
    Styled.widget(child: child)
        .padding(
          top: paddingTop,
          bottom: paddingBottom,
          left: paddingLeft,
          right: paddingRight,
        )
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor)
        .alignment(Alignment.center);

final blankPageSkeletonWidgetIconContainer = (
  BuildContext context,
) =>
    SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.height * 0.2,
      child: CircleSkeletonElementWidget(),
    ).padding(
      top: 20,
      bottom: 15,
    );
