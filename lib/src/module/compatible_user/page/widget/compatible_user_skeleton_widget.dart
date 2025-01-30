import 'package:flutter/material.dart';

import '../../../base/page/widget/skeleton/circle_list_skeleton_widget.dart';

class CompatibleUserSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleListSkeletonWidget(
      circleItemCount: 3,
    );
  }
}
