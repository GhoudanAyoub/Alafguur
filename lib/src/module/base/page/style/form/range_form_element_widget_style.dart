import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../widget/form/form_builder_widget.dart';

final rangeFormElementLabelTextContainer = (
  String? message,
  Color? textColor,
  double? labelFontSize,
  FontWeight? labelFontWeight,
) =>
    Text(message!)
        .textColor(textColor!)
        .fontSize(labelFontSize!)
        .fontWeight(labelFontWeight!)
        .padding(bottom: 8, top: 8);

final rangeFormElementValuesLabelTextContainer = (
  String? message,
  Color? textColor,
  double? fontSize,
) =>
    Text(message!).textColor(textColor!).fontSize(fontSize!).padding(all: 8);

final rangeFormElementRangeContainer = (
  Widget range,
) =>
    range.padding(bottom: 5);

final rangeFormElementDecorationContainer =
    (FormTheme? formTheme) => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: formTheme!.borderWidth!,
              color: formTheme.borderColor!,
            ),
          ),
        );

final rangeFormElementSliderThemeData = () => SliderThemeData(
      trackHeight: 1,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
      activeTrackColor: AppSettingsService.themeCommonAccentColor,
      inactiveTrackColor:
          AppSettingsService.themeCommonAccentColor.withOpacity(0.5),
      thumbColor: AppSettingsService.themeCommonAccentColor,
    );
