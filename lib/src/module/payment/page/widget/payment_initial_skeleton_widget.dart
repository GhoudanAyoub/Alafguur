import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../base/page/widget/skeleton/bar_skeleton_element_widget.dart';
import '../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../style/payment_initial_skeleton_widget_style.dart';

class PaymentInitialSkeletonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return paymentInitialSkeletonWidgetContainer(
      [
        BarSkeletonElementWidget(
          width: 160,
          height: 16,
          paddingLeft: 20,
          paddingRight: 20,
          paddingTop: 20,
          paddingBottom: 0,
          borderRadius: 11,
        ),
        ListSkeletonWidget(
          listPaddingTop: 10,
        ),
      ],
    );
  }
}
