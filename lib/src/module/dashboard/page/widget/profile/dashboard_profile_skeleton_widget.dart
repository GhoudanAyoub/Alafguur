import 'package:flutter/material.dart';

import '../../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../style/profile/dashboard_profile_skeleton_widget_style.dart';

class DashboardProfileSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return dashboardProfileSkeletonWidgetWrapperContainer(
      Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              dashboardProfileSkeletonWidgetAvatarContainer(
                context,
              ),
              BarSkeletonElementWidget(
                height: MediaQuery.of(context).size.width * 0.6,
                width: MediaQuery.of(context).size.width * 0.9,
                paddingTop: 69,
                paddingBottom: 36,
              ),
            ],
          ),
          BarSkeletonElementWidget(
            height: 10,
            width: 175,
            paddingBottom: 25,
          ),
          BarSkeletonElementWidget(
            height: 10,
            width: 175,
            paddingBottom: 25,
          ),
          BarSkeletonElementWidget(
            height: 10,
            width: 175,
            paddingBottom: 25,
          ),
          BarSkeletonElementWidget(
            height: 10,
            width: 175,
            paddingBottom: 25,
          ),
        ],
      ),
    );
  }
}
