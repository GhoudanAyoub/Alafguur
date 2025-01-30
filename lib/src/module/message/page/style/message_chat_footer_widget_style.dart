import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/model/form/form_element_model.dart';

Widget messageChatFooterWidgetWrapContainer(
  List<Widget> children,
  bool isSendMessageAreaPromoted,
) {
  if (isSendMessageAreaPromoted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    ).height(65).decorated(
          color: isSendMessageAreaPromoted
              ? AppSettingsService.themeCommonAccentColor
              : AppSettingsService.themeCommonScaffoldLightColor,
        );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  ).decorated(
    color: isSendMessageAreaPromoted
        ? AppSettingsService.themeCommonAccentColor
        : AppSettingsService.themeCommonScaffoldLightColor,
  );
}

final messageChatFooterWidgetAttachmentContainer = (
  Function clickCallback,
  bool isSendMessageAreaPromoted,
) =>
    Styled.widget(
      child: Icon(
        Icons.image,
        color: isSendMessageAreaPromoted
            ? AppSettingsService.themeCommonMessageChatPromotedContentColor
                .withOpacity(0.5)
            : AppSettingsService.themeCommonMessageChatAttachmentIconColor,
        size: 23,
      ),
    )
        .gestures(
          onTap: () => clickCallback(),
        )
        .padding(horizontal: 9);

final messageChatFooterWidgetTextareaContainer = (
  Widget? child,
) =>
    Styled.widget(child: child)
        .padding(horizontal: 8)
        .decorated(
          color: AppSettingsService.themeCommonScaffoldDefaultColor,
          borderRadius: BorderRadius.circular(6),
        )
        .padding(vertical: 12);

final messageChatFooterWidgetTextareaPromotedContainer = (
  String? message,
) =>
    Styled.widget(
      child: Text(
        message!,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        maxLines: 2,
      )
          .fontSize(
            16,
          )
          .textColor(
            AppSettingsService.themeCommonAccentColor,
          ),
    )
        .padding(
          all: 8,
        )
        .decorated(
          color: AppSettingsService.themeCommonMessageChatPromotedContentColor
              .withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        );

final messageChatFooterWidgetSendMessageButtonContainer = (
  String? label,
  Function clickCallback,
  bool isMessageValid,
  bool isSendMessageAreaPromoted,
) =>
    TextButton(
      onPressed: isMessageValid ? () => clickCallback() : null,
      child: Text(label!).fontSize(17).textColor(
            isSendMessageAreaPromoted
                ? AppSettingsService.themeCommonMessageChatPromotedContentColor
                    .withOpacity(0.5)
                : AppSettingsService.themeCommonAccentColor,
          ),
    ).padding(horizontal: 7);

final messageChatFooterWidgetFormTheme = () => FormTheme(
      borderWidth: 0,
      borderColor: transparentColor(),
    );

FormRendererCallback messageChatFooterWidgetFormRenderer() {
  return (
    Map<String, Widget> presentationMap,
    Map<String, FormElementModel> elementMap,
    BuildContext context,
  ) {
    // we need only a one raw form's field
    return presentationMap['message'];
  };
}
