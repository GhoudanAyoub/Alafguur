import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import '../../../../../app/service/app_settings_service.dart';

typedef LinkClickCallback = Function(String url);

final messageTypeOembedWidgetContainer = (
  String message,
  LinkClickCallback linkClickCallback,
  bool isMessageByAuthor,
) =>
    Column(
      children: [
        Linkify(
          onOpen: (link) => linkClickCallback(link.url),
          text: message,
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
      ],
    );
