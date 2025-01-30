import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

Widget paymentCreditActionsInfoWidgetActionWraperContainer(
  String title,
  String amount,
  BuildContext context,
) {
  bool isRtlModeActive = isRtlMode(context);
  return Row(
    children: [
      Expanded(
        child: Text(title)
            .textColor(AppSettingsService.themeCommonTextColor)
            .fontSize(15),
      ),
      Text(amount)
          .textColor(AppSettingsService.themeCommonTextColor)
          .fontSize(15)
    ],
  ).padding(
    right: !isRtlModeActive ? 10 : 0,
    left: isRtlModeActive ? 10 : 0,
  );
}
