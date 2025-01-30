import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../style/skeleton/bar_skeleton_element_widget_style.dart';

class BarSkeletonElementWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double paddingTop;
  final double paddingRight;
  final double paddingBottom;
  final double paddingLeft;
  final List<Widget>? children;
  final Color? background;

  const BarSkeletonElementWidget({
    Key? key,
    this.width = double.infinity,
    this.height = 60,
    this.borderRadius = 6,
    this.paddingTop = 5,
    this.paddingRight = 5,
    this.paddingBottom = 5,
    this.paddingLeft = 5,
    this.children,
    this.background,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return barSkeletonElementContainer(
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children != null ? children! : [],
        ),
      ),
      width,
      height,
      borderRadius,
      paddingTop,
      paddingRight,
      paddingBottom,
      paddingLeft,
      background,
    );
  }
}
