import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/loading_spinner_widget.dart';
import '../../service/model/message_model.dart';

final messageChatBodyWidgetWrapperContainer = (
  List<Widget> children,
) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ).padding(
      horizontal: 16,
    );

final messageChatBodyWidgetHistoryLoadingContainer =
    () => LoadingSpinnerWidget().padding(vertical: 8);

Widget messageChatBodyWidgetBubbleWrapperContainer(
  List<Widget> children,
  bool isMessageByAuthor,
  BuildContext context,
) {
  bool isRtlModeActive = isRtlMode(context);

  if (isMessageByAuthor) {
    return Stack(
      children: children,
    )
        .padding(
          horizontal: 5,
          top: 5,
          bottom: 0,
        )
        .decorated(
          color: AppSettingsService.themeCommonAccentColor,
          borderRadius: BorderRadius.only(
            topLeft:
                !isRtlModeActive ? Radius.circular(10) : Radius.circular(0),
            topRight:
                !isRtlModeActive ? Radius.circular(0) : Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        )
        .constrained(
          minWidth: 85,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        )
        .alignment(!isRtlModeActive ? Alignment.topRight : Alignment.topLeft)
        .padding(bottom: 16);
  }

  // not author alignment
  return Stack(
    children: children,
  )
      .padding(
        horizontal: 5,
        top: 5,
        bottom: 0,
      )
      .decorated(
        color: AppSettingsService.isDarkMode
            ? AppSettingsService.themeCommonDividerColor
            : AppSettingsService.themeCommonScaffoldLightColor,
        borderRadius: BorderRadius.only(
          topLeft: !isRtlModeActive ? Radius.circular(0) : Radius.circular(10),
          topRight: !isRtlModeActive ? Radius.circular(10) : Radius.circular(0),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      )
      .constrained(
        minWidth: 85,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      )
      .alignment(!isRtlModeActive ? Alignment.topLeft : Alignment.topRight)
      .padding(bottom: 16);
}

Widget messageChatBodyWidgetSentMessageContainer(
  Widget message,
  BuildContext context, {
  String? error,
  Function? errorClickCallback,
}) {
  bool isRtlModeActive = isRtlMode(context);
  return Row(
    children: [
      // a message body
      Expanded(
        child: Styled.widget(child: message),
      ),

      // a message's delivering error
      if (error != null && errorClickCallback != null)
        Styled.widget(
          child: Icon(
            SkMobileFont.ic_message_error,
            color: AppSettingsService.themeCommonIconLightColor,
            size: 14,
          )
              .backgroundColor(
                transparentColor(),
              )
              .gestures(
                onTap: () => errorClickCallback(),
              ),
        )
            .constrained(
              width: 28,
              height: 28,
            )
            .decorated(
              color: AppSettingsService.themeCommonAlertIconColor,
              shape: BoxShape.circle,
            )
            .padding(
              left: !isRtlModeActive ? 8 : 0,
              right: isRtlModeActive ? 8 : 0,
            ),
    ],
  );
}

final messageChatBodyWidgetMessageLoadingContainer =
    () => LoadingSpinnerWidget().padding(vertical: 8);

final messageChatBodyWidgetMessageDateContainer =
    (String? label) => Styled.widget(
          child: Text(
            label!.toUpperCase(),
          )
              .fontSize(12)
              .textColor(
                AppSettingsService.themeCommonMessageChatDateColor,
              )
              .textAlignment(TextAlign.center),
        ).width(double.infinity).padding(vertical: 14);

final messageChatBodyWidgetMessageReadingPromotedContainer = (
  String? message,
  Function clickCallback,
  bool isMessageByAuthor,
) =>
    Row(
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Icon(
            Icons.file_upload,
            color: AppSettingsService.themeCommonIconLightColor,
            size: 16,
          ),
        ).decorated(
          shape: BoxShape.circle,
          color: AppSettingsService.themeCommonAccentColor,
        ),
        Expanded(
          child: Text(
            message!,
            softWrap: true,
          ).textColor(AppSettingsService.themeCommonAccentColor).padding(
                horizontal: 8,
              ),
        ),
      ],
    )
        .padding(all: 8)
        .decorated(
          color: isMessageByAuthor
              ? AppSettingsService.themeCommonHardcodedWhiteColor
              : AppSettingsService.themeCommonAccentColor.withOpacity(0.25),
          borderRadius: BorderRadius.circular(4),
        )
        .gestures(
          onTap: () => clickCallback(),
        );

final messageChatBodyWidgetMessageReadingDeniedContainer = (
  String? message,
  bool isMessageByAuthor,
) =>
    isMessageByAuthor
        ? Text(message!).textColor(
            AppSettingsService.themeCommonHardcodedWhiteColor,
          )
        : Text(message!).textColor(AppSettingsService.themeCommonTextColor);

final messageChatBodyWidgetMessageWrapperContainer = (
  List<Widget> children,
) =>
    Stack(
      alignment: AlignmentDirectional.topEnd,
      children: children,
    ).padding(bottom: 25);

Widget messageChatBodyWidgetMessageTimeContainer(
  MessageModel message,
  BuildContext context,
  bool isMessageByAuthor, {
  bool isWink = false,
}) {
  bool isRtlModeActive = isRtlMode(context);

  return Positioned.directional(
    end: !isRtlModeActive ? 0 : null,
    start: isRtlModeActive ? 0 : null,
    bottom: 0,
    textDirection: TextDirection.ltr,
    child: Row(
      mainAxisAlignment:
          !isRtlModeActive ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!message.isPending) ...[
          // a time
          if (isWink)
            Text(message.time!).fontSize(13).textColor(
                  AppSettingsService.themeCommonMessageChatWinkTimeColor,
                ),

          // a time
          if (!isWink)
            if (isMessageByAuthor)
              Text(message.time!)
                  .fontSize(13)
                  .textColor(
                    AppSettingsService.themeCommonHardcodedWhiteColor,
                  )
                  .opacity(0.5)
            else
              Text(
                message.time!,
              )
                  .textColor(AppSettingsService.themeCommonTextColor)
                  .fontSize(13)
                  .opacity(0.5),

          // a sent icon
          if (message.isAuthor && !message.isRecipientRead)
            Icon(
              Icons.done,
              color: !isWink
                  ? AppSettingsService.themeCommonIconLightColor
                      .withOpacity(0.5)
                  : AppSettingsService.themeCommonMessageChatWinkTimeColor,
              size: 14,
            ),

          // a received icon
          if (message.isAuthor && message.isRecipientRead)
            Icon(
              Icons.done_all,
              color: !isWink
                  ? AppSettingsService.themeCommonIconLightColor
                      .withOpacity(0.5)
                  : AppSettingsService.themeCommonMessageChatWinkTimeColor,
              size: 14,
            ).padding(
              left: !isRtlModeActive ? 2 : 0,
              right: isRtlModeActive ? 2 : 0,
            ),
        ],

        // a pending icon
        if (message.isPending && message.error == null)
          Icon(
            SkMobileFont.ic_clock,
            color:
                AppSettingsService.themeCommonIconLightColor.withOpacity(0.5),
            size: 11,
          ).padding(
            left: !isRtlModeActive ? 2 : 0,
            right: isRtlModeActive ? 2 : 0,
          ),
      ],
    ).padding(bottom: 5),
  );
}

final messageChatBodyWidgetUnreadMessageWrapperContainer = (
  String title,
) =>
    Styled.widget(
      child: <Widget>[
        messageChatBodyWidgetUnreadMessageDividerContainer(),
        messageChatBodyWidgetUnreadMessageLabelContainer(
          title.toUpperCase(),
        ),
        messageChatBodyWidgetUnreadMessageDividerContainer(),
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    )
        .backgroundColor(
          transparentColor(),
        )
        .padding(
          bottom: 16,
          top: 20,
        );

final Widget Function({Widget child})
    messageChatBodyWidgetUnreadMessageDividerContainer = ({
  Widget? child,
}) =>
        Styled.widget(
          child: Expanded(
            child: Divider(
              color: AppSettingsService.themeCommonAccentColor,
            ),
          ),
        );

final messageChatBodyWidgetUnreadMessageLabelContainer =
    (String message) => Text(
          message,
          style: TextStyle(
            color: AppSettingsService.themeCommonAccentColor,
            fontSize: 14,
          ),
        ).padding(horizontal: 20);
