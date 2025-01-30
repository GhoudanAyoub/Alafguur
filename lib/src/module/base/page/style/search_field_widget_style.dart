import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/service/app_settings_service.dart';
import 'common_widget_style.dart';

TextStyle searchFieldMaterialTextStyle(Color? textColor) {
  return TextStyle(
    color: textColor ?? null,
  );
}

InputDecoration searchFieldMaterialDecoration(
  Color? backgroundColor,
  Color? placeholderColor,
  String? placeholder,
  Widget? clearButton,
  Color? iconsColor,
  Color? borderInputColor,
) =>
    InputDecoration(
      hoverColor: transparentColor(),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
        borderSide:
            BorderSide(color: AppSettingsService.themeCommonDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
        borderSide: BorderSide(
          color: borderInputColor ?? transparentColor(),
        ),
      ),
      contentPadding: EdgeInsets.all(0),
      prefixIcon: Icon(
        CupertinoIcons.search,
        color: iconsColor ?? AppSettingsService.themeCommonAccentColor,
        size: 20,
      ),
      suffixIcon: clearButton,
      filled: backgroundColor != null,
      fillColor: backgroundColor ?? null,
      hintText: placeholder,
      hintStyle: searchFieldMaterialTextStyle(placeholderColor),
    );
