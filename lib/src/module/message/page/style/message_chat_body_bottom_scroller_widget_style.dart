import 'package:flutter/cupertino.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';

final messageChatBodyBottomScrollerWidgetContainer = (
  BuildContext context,
  Function clickCallback,
  int unreadMessagesCount,
) =>
    Stack(
      children: [
        Positioned.directional(
          textDirection:
              isRtlMode(context) ? TextDirection.rtl : TextDirection.ltr,
          bottom: 132,
          end: 0,
          child: Stack(
            children: [
              Styled.widget(
                child: Icon(
                  CupertinoIcons.chevron_down,
                  color: AppSettingsService
                      .themeCommonMessageChatScrollerIconColor,
                  size: 26,
                )
                    .padding(top: 3)
                    .alignment(Alignment.center)
                    .constrained(
                      width: 50,
                      height: 50,
                    )
                    .decorated(
                      color: AppSettingsService.themeCommonScaffoldLightColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppSettingsService
                              .themeCommonScaffoldDefaultColor),
                    ),
              )
                  .padding(
                    horizontal: 20,
                    vertical: 10,
                  )
                  .alignment(Alignment.center)
                  .gestures(
                    onTap: () => clickCallback(),
                  ),
              if (unreadMessagesCount > 0)
                Positioned(
                  right: 16,
                  top: 5,
                  child: Styled.widget(
                    child: Text(
                      unreadMessagesCount <= 99
                          ? unreadMessagesCount.toString()
                          : '99+',
                    ).fontSize(12).textColor(
                        AppSettingsService.themeCommonHardcodedWhiteColor),
                  )
                      .padding(all: 6)
                      .decorated(
                        color: AppSettingsService.themeCommonSuccessIconColor,
                        shape: BoxShape.circle,
                      )
                      .alignment(Alignment.topRight),
                ),
            ],
          ),
        ),
      ],
    );
