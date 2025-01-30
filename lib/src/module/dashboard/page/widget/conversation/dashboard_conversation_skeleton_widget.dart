import 'package:flutter/material.dart';

import '../../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../../../base/page/widget/skeleton/circle_list_skeleton_widget.dart';
import '../../style/conversation/dashboard_conversation_skeleton_widget_style.dart';

class DashboardConversationSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return dashboardConversationSkeletonWidgetWrapperContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarSkeletonElementWidget(
            width: 82,
            height: 10,
            paddingBottom: 10,
            paddingLeft: 16,
            paddingRight: 16,
          ),
          CircleListSkeletonWidget(),
        ],
      ),
    );
  }
}
