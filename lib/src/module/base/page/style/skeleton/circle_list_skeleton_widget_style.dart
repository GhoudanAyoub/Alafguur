import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

final Widget Function(Widget, {double paddingBottom, double paddingLeft, double paddingRight, double paddingTop}) circleListSkeletonContainer = (
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

final Widget Function(List<Widget>, {double paddingBottom, double paddingLeft, double paddingRight, double paddingTop}) circleListItemWrapSkeletonContainer = (
  List<Widget> child, {
  double? paddingTop,
  double? paddingBottom,
  double? paddingLeft,
  double? paddingRight,
}) =>
    Row(
      children: child,
    ).padding(
      top: paddingTop,
      bottom: paddingBottom,
      left: paddingLeft,
      right: paddingRight,
    );

final circleListItemCircleWrapSkeletonContainer = (
  Widget child, {
  double circleWrapWidth = 80,
  double circleWrapHeight = 80,
}) =>
    Styled.widget(child: child).width(circleWrapWidth).height(circleWrapHeight);
