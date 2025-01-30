import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/distance_widget_mixin.dart';
import '../../../../base/page/widget/navigation_widget_mixin.dart';
import '../../../../base/page/widget/user_card_widget_mixin.dart';
import '../../state/dashboard_hot_list_state.dart';

class DashboardHotListUserWidget extends StatelessWidget
    with NavigationWidgetMixin, UserCardWidgetMixin, DistanceWidgetMixin {
  final ScrollController scrollController;
  final DashboardHotListState state;

  const DashboardHotListUserWidget({
    Key? key,
    required this.scrollController,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        controller: scrollController,
        itemCount: state.hotList.length,
        cacheExtent: MediaQuery.of(context).size.height * 2,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getCardsCountPerRow(context),
          childAspectRatio: 2.09 / 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          return userCardContainer(
            user: state.hotList[index].user,
            distance: state.hotList[index].user.distance != null
                ? getDistance(state.hotList[index].user, context)
                : null,
          ).gestures(
            onTap: () => redirectToProfilePage(
              context,
              state.hotList[index].user.id,
            ),
          );
        },
      ),
    );
  }
}
