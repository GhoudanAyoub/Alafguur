import 'package:flutter/material.dart';

import '../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../style/edit_photo_skeleton_widget_style.dart';

class EditPhotoSkeletonWidget extends StatelessWidget {
  final int itemCount;

  const EditPhotoSkeletonWidget({
    Key? key,
    this.itemCount = 9,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        editPhotoSkeletonWidgetBodyContainer(
          GridView.builder(
            itemCount: itemCount,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemBuilder: (BuildContext context, int index) =>
                BarSkeletonElementWidget(
              borderRadius: 10,
            ),
          ),
        ),
      ],
    );
  }
}
