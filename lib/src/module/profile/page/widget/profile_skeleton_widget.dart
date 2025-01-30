import 'package:flutter/material.dart';

import '../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../../base/page/widget/skeleton/circle_skeleton_element_widget.dart';
import '../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../style/profile_skeleton_widget_style.dart';

class ProfileSkeletonWidget extends StatelessWidget {
  final bool? isProfileOwner;

  const ProfileSkeletonWidget({Key? key, this.isProfileOwner})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BarSkeletonElementWidget(
                    height: MediaQuery.of(context).size.height / 2.2,
                    paddingLeft: 0,
                    paddingRight: 0,
                    paddingTop: 0,
                    borderRadius: 0,
                  ),
                  ListSkeletonWidget(
                    barsCount: 2,
                  ),
                ],
              ),
            ),
          ),
          if (!isProfileOwner!)
            profileSkeletonWidgetButtonsWrapperContainer(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  profileSkeletonWidgetButtonContainer(
                    CircleSkeletonElementWidget(),
                  ),
                  profileSkeletonWidgetButtonContainer(
                    CircleSkeletonElementWidget(),
                  ),
                  profileSkeletonWidgetButtonContainer(
                    CircleSkeletonElementWidget(),
                  ),
                  profileSkeletonWidgetButtonContainer(
                    CircleSkeletonElementWidget(),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
