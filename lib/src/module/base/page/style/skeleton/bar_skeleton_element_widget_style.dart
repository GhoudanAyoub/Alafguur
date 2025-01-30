import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';

final barSkeletonElementContainer = (
  Widget child,
  double width,
  double height,
  double borderRadius,
  double paddingTop,
  double paddingRight,
  double paddingBottom,
  double paddingLeft,
  Color? backgroundColor,
) =>
    Styled.widget(child: child)
        .width(width)
        .height(height)
        .decorated(
          color: backgroundColor != null
              ? backgroundColor
              : AppSettingsService.themeCommonSkeletonColor,
          borderRadius: BorderRadius.circular(borderRadius),
        )
        .padding(
          top: paddingTop,
          right: paddingRight,
          bottom: paddingBottom,
          left: paddingLeft,
        );
