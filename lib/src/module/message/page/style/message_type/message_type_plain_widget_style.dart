import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/widget/image_loader_widget.dart';
import '../../../service/model/message_attachment_model.dart';
import '../../../service/model/message_model.dart';

typedef LinkClickCallback = Function(String url);
typedef AttachmentClickCallback = Function(String url);

final messageTypePlainWidgetContainer = (
  MessageModel message,
  LinkClickCallback linkClickCallback,
  AttachmentClickCallback imageClickCallback,
  AttachmentClickCallback docClickCallback,
  bool isMessageByAuthor,
  BuildContext context, {
  double imageWidth = 200,
}) =>
    Column(
      children: [
        // a message text
        if (message.attachments.isEmpty)
          Linkify(
            onOpen: (link) => linkClickCallback(link.url),
            text: message.text!,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isMessageByAuthor
                  ? AppSettingsService.themeCommonHardcodedWhiteColor
                  : AppSettingsService.themeCommonTextColor,
            ),
            linkStyle: TextStyle(
              color: isMessageByAuthor
                  ? AppSettingsService.themeCommonHardcodedWhiteColor
                  : AppSettingsService.themeCommonTextColor,
              fontSize: 16,
            ),
          ),
        // photos and docs
        if (message.attachments.isNotEmpty) ...[
          ...message.attachments
              .where(
                (attachment) => attachment.type == AttachmentTypeEnum.image,
              )
              .toList()
              .map(
                (attachment) => (attachment.bytes == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ImageLoaderWidget(
                              imageUrl: attachment.downloadUrl,
                              width: imageWidth,
                              height: null,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              attachment.bytes!,
                              width: imageWidth,
                              height: null,
                            ),
                          ))
                    .gestures(
                  onTap: () => imageClickCallback(
                    attachment.downloadUrl,
                  ),
                ),
              ),
          ...message.attachments
              .where(
                (attachment) => attachment.type == AttachmentTypeEnum.doc,
              )
              .toList()
              .map(
                (attachment) => Row(
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: Icon(
                        Icons.text_snippet,
                        color: AppSettingsService.themeCommonIconLightColor,
                        size: 16,
                      ),
                    ).decorated(
                      shape: BoxShape.circle,
                      color: AppSettingsService.themeCommonAccentColor,
                    ),
                    Expanded(
                      child: Text(
                        attachment.fileName,
                        softWrap: true,
                      )
                          .textColor(AppSettingsService.themeCommonAccentColor)
                          .padding(
                            horizontal: 8,
                          ),
                    ),
                  ],
                )
                    .padding(all: 8)
                    .decorated(
                      color: isMessageByAuthor
                          ? AppSettingsService.themeCommonHardcodedWhiteColor
                          : AppSettingsService.themeCommonAccentColor
                              .withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    )
                    .gestures(
                      onTap: () => docClickCallback(
                        attachment.downloadUrl,
                      ),
                    ),
              ),
        ]
      ],
    );
