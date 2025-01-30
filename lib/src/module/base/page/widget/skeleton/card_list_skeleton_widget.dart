import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../user_card_widget_mixin.dart';
import 'bar_skeleton_element_widget.dart';
import 'card_skeleton_element_widget.dart';

class CardListSkeletonWidget extends StatelessWidget with UserCardWidgetMixin {
  final int? itemCount;
  final double firstSubBarWidth;
  final double firstSubBarHeight;
  final double firstSubBarPaddingLeft;
  final double firstSubBarPaddingRight;
  final double secondSubBarWidth;
  final double secondSubBarHeight;
  final double secondSubBarPaddingLeft;
  final double secondSubBarPaddingRight;

  const CardListSkeletonWidget({
    Key? key,
    this.itemCount,
    this.firstSubBarWidth = 100,
    this.firstSubBarHeight = 10,
    this.firstSubBarPaddingLeft = 20,
    this.firstSubBarPaddingRight = 20,
    this.secondSubBarWidth = 100,
    this.secondSubBarHeight = 10,
    this.secondSubBarPaddingLeft = 20,
    this.secondSubBarPaddingRight = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getCardsCountPerRow(context),
          childAspectRatio: 2.09 / 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          return CardSkeletonElementWidget(
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
          );
        },
      ),
    );
  }
}
