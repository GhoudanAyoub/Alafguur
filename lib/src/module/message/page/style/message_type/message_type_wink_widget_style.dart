import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../service/model/message_model.dart';

Widget messageTypeWinkWidgetWrapperContainer(
  List<Widget> children,
  BuildContext context,
  bool isMessageByAuthor,
) {
  bool isRtlModeActive = isRtlMode(context);
  if (isMessageByAuthor) {
    return Row(
      textDirection: !isRtlModeActive ? TextDirection.rtl : TextDirection.ltr,
      children: children,
    ).padding(bottom: 16);
  }

  return Row(
    textDirection: !isRtlModeActive ? TextDirection.ltr : TextDirection.rtl,
    children: children,
  ).padding(bottom: 16);
}

Widget messageTypeWinkWidgetTextWrapperContainer(
  List<Widget> children,
  bool isMessageByAuthor,
  BuildContext context,
) {
  bool isRtlModeActive = isRtlMode(context);
  if (isMessageByAuthor) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: children,
    ).padding(
      right: !isRtlModeActive ? 10 : 0,
      left: isRtlModeActive ? 10 : 0,
    );
  }
  return Stack(
    alignment: AlignmentDirectional.bottomEnd,
    children: children,
  ).padding(
    right: isRtlModeActive ? 16 : 0,
    left: !isRtlModeActive ? 16 : 0,
  );
}

final messageTypeWinkWidgetIconContainer = (
  MessageModel message,
) =>
    Wrap(
      children: [
        // a sent icon
        if (message.isAuthor)
          Icon(
            SkMobileFont.ic_wink,
            color: AppSettingsService.themeCommonAccentColor,
            size: 56,
          ),

        // a received icon
        if (!message.isAuthor)
          Icon(
            SkMobileFont.ic_wink,
            color:
                AppSettingsService.themeCommonMessageChatWinkReceivedIconColor,
            size: 116,
          ),
      ],
    );

final messageTypeWinkWidgetTextContainer = (
  MessageModel message,
  String? sentDescription,
  String? receivedDescription,
) =>
    Wrap(
      children: [
        // a sent descr
        if (message.isAuthor)
          Text(sentDescription!)
              .textColor(AppSettingsService.themeCommonTextColor)
              .fontSize(16),

        // a received descr
        if (!message.isAuthor)
          Text(receivedDescription!)
              .textColor(AppSettingsService.themeCommonTextColor)
              .fontSize(16),
      ],
    ).padding(
      bottom: 22,
    );
