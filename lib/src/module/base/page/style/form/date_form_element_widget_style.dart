
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../widget/form/form_builder_widget.dart';

final dateFormElementLabelTextContainer = (
  String? message,
  Color? labelColor,
  double? labelFontSize,
  FontWeight? labelFontWeight,
) =>
    Text(message!)
        .textColor(labelColor!)
        .fontSize(labelFontSize!)
        .fontWeight(labelFontWeight!);

final dateFormElementValueTextContainer = (
  String? value,
  Color? textColor,
  double? fontSize,
) =>
    Container(
      child: Text(
        value!,
        overflow: TextOverflow.ellipsis,
      ).textColor(textColor!).fontSize(fontSize!).padding(top: 8),
    );

final dateFormElementDecorationContainer =
    (FormTheme? formTheme) => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: formTheme!.borderWidth!,
              color: formTheme.borderColor!,
            ),
          ),
        );

final dateFormElementContainer = (
  Widget formElement,
) =>
    formElement.padding(top: 8, bottom: 8);
