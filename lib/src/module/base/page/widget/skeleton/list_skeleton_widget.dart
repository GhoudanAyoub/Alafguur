import 'package:flutter/widgets.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../style/skeleton/list_skeleton_widget_style.dart';
import 'bar_skeleton_element_widget.dart';

class ListSkeletonWidget extends StatelessWidget {
  final int barsCount;
  final double mainBarHeight;
  final double firstSubBarWidth;
  final double firstSubBarHeight;
  final double firstSubBarPaddingLeft;
  final double firstSubBarPaddingRight;
  final double secondSubBarWidth;
  final double secondSubBarHeight;
  final double secondSubBarPaddingLeft;
  final double secondSubBarPaddingRight;
  final double listPaddingTop;
  final double listPaddingBottom;
  final double listPaddingLeft;
  final double listPaddingRight;

  const ListSkeletonWidget({
    Key? key,
    this.barsCount = 4,
    this.mainBarHeight = 70,
    this.firstSubBarWidth = 40,
    this.firstSubBarHeight = 10,
    this.firstSubBarPaddingLeft = 20,
    this.firstSubBarPaddingRight = 20,
    this.secondSubBarWidth = 160,
    this.secondSubBarHeight = 10,
    this.secondSubBarPaddingLeft = 20,
    this.secondSubBarPaddingRight = 20,
    this.listPaddingTop = 16,
    this.listPaddingBottom = 16,
    this.listPaddingLeft = 16,
    this.listPaddingRight = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return listSkeletonContainer(
      Column(
        children: _getBarWidgets(),
      ),
      paddingTop: listPaddingTop,
      paddingBottom: listPaddingBottom,
      paddingLeft: listPaddingLeft,
      paddingRight: listPaddingRight,
    );
  }

  List<Widget> _getBarWidgets() {
    List<Widget> list = [];

    for (var i = 0; i < barsCount; i++) {
      list.add(
        BarSkeletonElementWidget(
          height: mainBarHeight,
          children: [
            BarSkeletonElementWidget(
              width: firstSubBarWidth,
              height: firstSubBarHeight,
              paddingLeft: firstSubBarPaddingLeft,
              paddingRight: firstSubBarPaddingRight,
              background: AppSettingsService.themeCommonSkeletonLightColor,
            ),
            BarSkeletonElementWidget(
              width: secondSubBarWidth,
              height: secondSubBarHeight,
              paddingLeft: secondSubBarPaddingLeft,
              paddingRight: secondSubBarPaddingRight,
              background: AppSettingsService.themeCommonSkeletonLightColor,
            ),
          ],
        ),
      );
    }
    return list;
  }
}
