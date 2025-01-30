import 'package:flutter/material.dart';

import '../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import 'edit_photo_skeleton_widget.dart';

class EditSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditPhotoSkeletonWidget(),
        ListSkeletonWidget(barsCount: 2),
      ],
    );
  }
}
