import 'package:flutter/widgets.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../style/skeleton/circle_list_skeleton_widget_style.dart';
import 'bar_skeleton_element_widget.dart';
import 'circle_skeleton_element_widget.dart';

class CircleListSkeletonWidget extends StatelessWidget {
  final int circleItemCount;
  final double firstSubBarWidth;
  final double firstSubBarHeight;
  final double firstSubBarPaddingLeft;
  final double firstSubBarPaddingRight;
  final double secondSubBarWidth;
  final double secondSubBarHeight;
  final double secondSubBarPaddingLeft;
  final double secondSubBarPaddingRight;
  final double circleListPaddingTop;
  final double circleListPaddingBottom;
  final double circleListPaddingLeft;
  final double circleListPaddingRight;
  final double circleListItemPaddingTop;
  final double circleListItemPaddingBottom;
  final double circleListItemPaddingLeft;
  final double circleListItemPaddingRight;

  const CircleListSkeletonWidget({
    Key? key,
    this.circleItemCount = 4,
    this.firstSubBarWidth = 85,
    this.firstSubBarHeight = 10,
    this.firstSubBarPaddingLeft = 20,
    this.firstSubBarPaddingRight = 20,
    this.secondSubBarWidth = 60,
    this.secondSubBarHeight = 10,
    this.secondSubBarPaddingLeft = 20,
    this.secondSubBarPaddingRight = 20,
    this.circleListPaddingTop = 16,
    this.circleListPaddingBottom = 16,
    this.circleListPaddingLeft = 16,
    this.circleListPaddingRight = 16,
    this.circleListItemPaddingTop = 0,
    this.circleListItemPaddingBottom = 16,
    this.circleListItemPaddingLeft = 0,
    this.circleListItemPaddingRight = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return circleListSkeletonContainer(
      Column(
        children: _getCircleItemWidgets(),
      ),
      paddingTop: circleListPaddingTop,
      paddingBottom: circleListPaddingBottom,
      paddingLeft: circleListPaddingLeft,
      paddingRight: circleListPaddingRight,
    );
  }

  List<Widget> _getCircleItemWidgets() {
    List<Widget> list = [];

    for (var i = 0; i < circleItemCount; i++) {
      list.add(
        circleListItemWrapSkeletonContainer(
          <Widget>[
            circleListItemCircleWrapSkeletonContainer(
              CircleSkeletonElementWidget(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BarSkeletonElementWidget(
                  width: firstSubBarWidth,
                  height: firstSubBarHeight,
                  paddingLeft: firstSubBarPaddingLeft,
                  paddingRight: firstSubBarPaddingRight,
                  background: AppSettingsService.themeCommonSkeletonColor,
                ),
                BarSkeletonElementWidget(
                  width: secondSubBarWidth,
                  height: secondSubBarHeight,
                  paddingLeft: secondSubBarPaddingLeft,
                  paddingRight: secondSubBarPaddingRight,
                  background: AppSettingsService.themeCommonSkeletonColor,
                ),
              ],
            ),
          ],
          paddingTop: circleListItemPaddingTop,
          paddingBottom: circleListItemPaddingBottom,
          paddingLeft: circleListItemPaddingLeft,
          paddingRight: circleListItemPaddingRight,
        ),
      );
    }
    return list;
  }
}
