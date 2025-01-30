import 'package:flutter/material.dart';

import '../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../style/join_initial_skeleton_widget_style.dart';

class JoinInitialSkeletonWidget extends StatelessWidget {
  final double avatarWidth;
  final double avatarHeight;

  const JoinInitialSkeletonWidget({
    Key? key,
    this.avatarWidth = 180,
    this.avatarHeight = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return joinInitialSkeletonContainer(
      Column(
        children: [
          // an avatar
          joinInitialAvatarSkeletonContainer(
            BarSkeletonElementWidget(
              width: avatarWidth,
              height: avatarHeight,
            ),
          ),
          // form elements
          ListSkeletonWidget(barsCount: 2),
        ],
      ),
    );
  }
}
