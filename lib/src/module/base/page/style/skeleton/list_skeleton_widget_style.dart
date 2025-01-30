import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

final Widget Function(Widget, {double paddingBottom, double paddingLeft, double paddingRight, double paddingTop}) listSkeletonContainer = (
  Widget child, {
  double? paddingTop,
  double? paddingBottom,
  double? paddingLeft,
  double? paddingRight,
}) =>
    Styled.widget(child: child).padding(
      top: paddingTop,
      bottom: paddingBottom,
      left: paddingLeft,
      right: paddingRight,
    );
