
import '../../widget/form/form_builder_widget.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../common_widget_style.dart';

final googleMapLocationFormFieldLabelTextContainer = (
  String? message,
  Color? labelColor,
  double? labelFontSize,
  FontWeight? labelFontWeight,
) =>
    Text(message!)
        .textColor(labelColor!)
        .fontSize(labelFontSize!)
        .fontWeight(labelFontWeight!);

final googleMapLocationFormFieldValueTextContainer = (
  String? value,
  Color? textColor,
  double? fontSize,
) =>
    Container(
      child: Text(value!, overflow: TextOverflow.ellipsis)
          .textColor(textColor!)
          .fontSize(fontSize!)
          .padding(top: 8),
    );

final googleMapLocationFormFieldDecorationContainer =
    (FormTheme? formTheme) => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: formTheme!.borderWidth!,
              color: formTheme.borderColor!,
            ),
          ),
        );

final googleMapLocationFormFieldContainer = (
  Widget formElement,
) =>
    formElement.padding(
      top: 8,
      bottom: 8,
    );

final googleMapLocationFormElementSliderThemeData = () => SliderThemeData(
      trackHeight: 1,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
      activeTrackColor: AppSettingsService.themeCommonAccentColor,
      inactiveTrackColor:
          AppSettingsService.themeCommonAccentColor.withOpacity(0.5),
      thumbColor: AppSettingsService.themeCommonAccentColor,
    );

final googleMapLocationFormElementSliderValueContainer = (
  Text child,
) =>
    child.textColor(
      AppSettingsService.themeCommonFormValueColor,
    );

final googleMapLocationPopupSearchContainer = (Widget widget) => widget
    .height(40)
    .padding(
      left: 16,
      right: 16,
      top: 8,
      bottom: 8,
    )
    .backgroundColor(
      AppSettingsService.themeCommonScaffoldDefaultColor,
    );

final googleMapLocationFormFieldPopupContainer = (Widget formElement) =>
    formElement
        .backgroundColor(AppSettingsService.themeCommonScaffoldLightColor);

final googleMapLocationPopupSearchResultDividerContainer = () => Divider(
    color: AppSettingsService.themeCommonDividerColor,
    height: 1,
    thickness: 1,
    indent: 16,
    endIndent: 0);

final googleMapLocationPopupSearchResultValueColorContainer = (
  Text child,
) =>
    child.textColor(
      AppSettingsService.themeCommonFormValueColor,
    );
final googleMapLocationFormFieldPopupButtonContainer = (
  String label,
  BuildContext context,
  Function clickCallback,
) =>
    Styled.widget(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppSettingsService.themeCommonSystemIconColor, backgroundColor: transparentColor(), disabledForegroundColor: transparentColor().withOpacity(0.38), disabledBackgroundColor: transparentColor().withOpacity(0.12),
          shadowColor: transparentColor(),
          elevation: 0,
          minimumSize: Size(200, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(64.0),
          ),
          side: BorderSide(
            width: 2,
            color: AppSettingsService.isDarkMode
                ? AppSettingsService.themeCommonFormPlaceholderColor
                : AppSettingsService.themeCommonDividerColor,
          ),
        ),
        child: Text(
          LocalizationService.of(context).t(label),
          style: TextStyle(
            fontSize: 18.0,
            color: AppSettingsService.isDarkMode
                ? AppSettingsService.themeCommonFormPlaceholderColor
                : AppSettingsService.themeCommonDividerColor,
          ),
        ),
        onPressed: () => clickCallback(),
      ).height(48).padding(all: 20).alignment(Alignment.center),
    );

final googleMapLocationFormFieldDistanceValueTextContainer =
    (Widget widget) => widget.padding(horizontal: 16);
