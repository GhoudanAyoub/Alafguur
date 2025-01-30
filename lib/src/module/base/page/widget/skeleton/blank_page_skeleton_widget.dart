import 'package:flutter/widgets.dart';

import '../../style/skeleton/blank_page_skeleton_widget_style.dart';
import 'bar_skeleton_element_widget.dart';
import 'list_skeleton_widget.dart';

class BlankPagesSkeletonWidget extends StatelessWidget {
  final bool formFields;
  final double pagePaddingTop;
  final double pagePaddingBottom;
  final double pagePaddingLeft;
  final double pagePaddingRight;

  const BlankPagesSkeletonWidget({
    Key? key,
    this.formFields = false,
    this.pagePaddingTop = 16,
    this.pagePaddingBottom = 16,
    this.pagePaddingLeft = 16,
    this.pagePaddingRight = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return blankPageSkeletonContainer(
      SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  blankPageSkeletonWidgetIconContainer(
                    context,
                  ),
                  BarSkeletonElementWidget(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  BarSkeletonElementWidget(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                  BarSkeletonElementWidget(
                    height: 10,
                    width: 80,
                  ),
                  if (formFields)
                    ListSkeletonWidget(
                      barsCount: 2,
                      listPaddingBottom: 0,
                    ),
                  BarSkeletonElementWidget(
                    height: 42,
                    width: 150,
                    borderRadius: 25,
                    paddingLeft: 7,
                    paddingRight: 7,
                    paddingTop: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      paddingTop: pagePaddingTop,
      paddingBottom: pagePaddingBottom,
      paddingLeft: pagePaddingLeft,
      paddingRight: pagePaddingRight,
    );
  }
}
