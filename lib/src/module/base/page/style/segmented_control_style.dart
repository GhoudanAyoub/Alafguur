import 'package:flutter/cupertino.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../app/service/app_settings_service.dart';

/// Segmented control that takes the maximum available width of its parent with
/// the given [padding] applied.
///
/// Displays the provided map of [children] in a horizontal list where each item
/// is selectable. Only one item can be selected at a time.
///
/// When the state of the segmented control changes, the [onValueChanged]
/// callback is called with the [children] map key of type [T] associated with
/// the newly selected item passed as the parameter. The widgets that use this
/// control should listen for the callback and rebuild the control with a
/// new [selectedValue].
Widget fullWidthSegmentedControl<T extends Object>({
  required Map<T, Widget> children,
  required ValueChanged<T> onValueChanged,
  required T selectedValue,
  EdgeInsetsGeometry padding = const EdgeInsets.only(
    top: 10,
    bottom: 10,
    left: 8,
    right: 8,
  ),
}) {
  return SizedBox(
    width: double.infinity,
    child: CupertinoSegmentedControl<T>(
      padding: padding,
      children: children,
      groupValue: selectedValue,
      onValueChanged: onValueChanged,
      unselectedColor: AppSettingsService.themeCommonScaffoldLightColor,
    ),
  ).backgroundColor(
    AppSettingsService.themeCommonScaffoldLightColor,
  );
}

/// Segmented control item that contains the given [title].
Widget defaultSegmentedControlItem({required String title}) {
  return Container(
    padding: EdgeInsets.all(6.0),
    child: AppSettingsService.isDarkMode
        ? Text(title)
            .textColor(
              AppSettingsService.isDarkMode
                  ? AppSettingsService.themeCommonSegmentedControlTextColor
                  : null,
            )
            .fontSize(15)
        : Text(title).fontSize(15),
  );
}
