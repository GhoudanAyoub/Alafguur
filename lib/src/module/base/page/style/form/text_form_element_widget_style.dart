import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../widget/form/form_builder_widget.dart';

final textFormElementLabelTextContainer = (
  String? message,
  bool isRtl,
  Color? labelColor,
  double? labelFontSize,
  FontWeight? labelFontWeight,
) =>
    Text(message!)
        .textColor(labelColor!)
        .fontSize(labelFontSize!)
        .fontWeight(labelFontWeight!)
        .alignment((isRtl ? Alignment.topRight : Alignment.topLeft))
        .padding(bottom: 0, top: 8);

final textFormElementFormFieldDecorationContainer =
    (FormTheme? formTheme) => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: formTheme!.borderWidth!,
              color: formTheme.borderColor!,
            ),
          ),
        );

BoxDecoration textFormElementCupertinoTextFieldDecoration() => BoxDecoration(
      border: Border(),
    );

EdgeInsets textFormElementCupertinoTextFieldPadding() {
  return EdgeInsets.fromLTRB(0, 8, 0, 8);
}

InputDecoration textFormElementMaterialTextFieldDecoration(
  String? placeholder,
  Color? placeholderColor,
  double? placeholderFontSize,
) =>
    InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      hintText: placeholder,
      isDense: true,
      hintStyle: TextStyle(
        color: placeholderColor,
        fontSize: placeholderFontSize,
      ),
    );
