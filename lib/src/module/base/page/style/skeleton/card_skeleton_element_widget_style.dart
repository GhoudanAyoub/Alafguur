import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';

final cardSkeletonElementContainer = (
  Widget child,
  double width,
  double height,
  double borderRadius,
  Color? backgroundColor,
  double? innerpaddingTop,
  double? innerpaddingRight,
  double innerpaddingBottom,
  double? innerpaddingLeft,
) =>
    Styled.widget(child: child)
        .width(width)
        .height(height)
        .padding(
          top: innerpaddingTop,
          right: innerpaddingRight,
          bottom: innerpaddingBottom,
          left: innerpaddingLeft,
        )
        .decorated(
          color: backgroundColor != null
              ? backgroundColor
              : AppSettingsService.themeCommonSkeletonColor,
          borderRadius: BorderRadius.circular(borderRadius),
        );
