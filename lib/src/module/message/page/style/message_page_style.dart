import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../base/page/style/common_widget_style.dart';

final messagePageMessagesBodyAreaContainer = (
  Widget child,
  bool isSendMessageAreaAllowed,
  bool isSendMessageAreaPromoted,
) =>
    Styled.widget(child: child).padding(
      bottom: isSendMessageAreaAllowed || isSendMessageAreaPromoted ? 65 : 0,
    );

final messagePageMessagesSendingAreaContainer = (
  BuildContext context,
  Widget child,
  Function clickCallback,
) =>
    Positioned.directional(
      textDirection: isRtlMode(context) ? TextDirection.rtl : TextDirection.ltr,
      bottom: 0,
      start: 0,
      end: 0,
      child: child.gestures(
        onTap: () => clickCallback(),
      ),
    );

Widget messagePageMessagesHeaderIconContainer(
  Function clickCallback,
  BuildContext context,
) {
  bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  return SizedBox(
    width: isIOS ? 16 : 30,
    height: 30,
    child: Icon(
      Icons.more_vert,
      size: 24,
    ).gestures(onTap: clickCallback as void Function()?),
  );
}
