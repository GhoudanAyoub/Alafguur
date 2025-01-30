import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../widget/form/form_builder_widget.dart';

final singleChoiceFormFieldDecorationContainer =
    (FormTheme? formTheme) => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: formTheme!.borderWidth!,
              color: formTheme.borderColor!,
            ),
          ),
        );

final singleChoiceFormFieldLabelTextContainer = (
  String? message,
  Color? labelColor,
  double? labelFontSize,
  FontWeight? labelFontWeight,
) =>
    Text(message!)
        .textColor(labelColor!)
        .fontSize(labelFontSize!)
        .fontWeight(labelFontWeight!);

final singleChoiceFormFieldContainer = (
  Widget formElement,
) =>
    formElement.padding(vertical: 8, horizontal: 4);
