import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../style/skeleton/card_skeleton_element_widget_style.dart';

class CardSkeletonElementWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final List<Widget>? children;
  final Color? background;
  final double? innerpaddingTop;
  final double? innerpaddingRight;
  final double innerpaddingBottom;
  final double? innerpaddingLeft;

  const CardSkeletonElementWidget({
    Key? key,
    this.width = double.infinity,
    this.height = 0,
    this.borderRadius = 8,
    this.children,
    this.background,
    this.innerpaddingTop,
    this.innerpaddingRight,
    this.innerpaddingBottom = 10,
    this.innerpaddingLeft,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return cardSkeletonElementContainer(
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: children != null ? children! : [],
        ),
      ),
      width,
      height,
      borderRadius,
      background,
      innerpaddingTop,
      innerpaddingRight,
      innerpaddingBottom,
      innerpaddingLeft,
    );
  }
}
