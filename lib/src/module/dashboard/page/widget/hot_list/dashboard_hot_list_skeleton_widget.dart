import 'package:flutter/material.dart';

import '../../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../../../base/page/widget/skeleton/card_list_skeleton_widget.dart';
import '../../style/hot_list/dashboard_hot_list_skeleton_widget_style.dart';

class DashboardHotListSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return hotListSkeletonWrapperContainer(
      Column(
        children: [
          CardListSkeletonWidget(
            itemCount: 4,
          ),
          BarSkeletonElementWidget(
            borderRadius: 64,
            width: 200,
            height: 44,
          ),
        ],
      ),
    );
  }
}
