import 'package:flutter/material.dart';

import '../../../../base/page/widget/skeleton/card_list_skeleton_widget.dart';
import '../../style/search/dashboard_search_skeleton_widget.dart';

class DashboardSearchSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return searchSkeletonWrapperContainer(
      Column(
        children: [
          CardListSkeletonWidget(
            itemCount: 4,
          ),
        ],
      ),
    );
  }
}
