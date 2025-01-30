import '../rtl_widget_mixin.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../service/localization_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../style/common_widget_style.dart';
import '../modal_widget_mixin.dart';
import 'form_builder_widget.dart';

mixin FormElementWidgetMixin on ModalWidgetMixin, RtlWidgetMixin {
  String? getLabel(
    FormElementModel formElementModel,
    BuildContext context,
  ) {
    if (formElementModel.label != null) {
      return LocalizationService.of(context).t(formElementModel.label!);
    }

    return '';
  }

  String? getPlaceholder(
    FormElementModel formElementModel,
    BuildContext context,
  ) {
    if (formElementModel.placeholder != null) {
      return LocalizationService.of(context).t(formElementModel.placeholder!);
    }

    return '';
  }

  bool isErrorAvailable(FormElementModel formElementModel) {
    if (formElementModel.displayValidationError &&
        formElementModel.errorMessage != null &&
        !formElementModel.isValid!) {
      return true;
    }

    return false;
  }

  Widget getErrorWidget(
    FormElementModel formElementModel,
    BuildContext context,
  ) {
    return getFormErrorIcon().gestures(
      onTap: () => showAlert(
        context,
        LocalizationService.of(context).t(formElementModel.errorMessage ?? ''),
      ),
    );
  }

  TextStyle? getTextStyle(
    Color? textColor,
    double? fontSize,
  ) {
    if (textColor != null) {
      return TextStyle(
        color: textColor,
        fontSize: fontSize,
      );
    }

    return null;
  }

  Color? getTextColor(FormTheme formTheme) {
    if (formTheme.textColor != null) {
      return formTheme.textColor;
    }

    return null;
  }

  Color? getPlaceholderColor(FormTheme formTheme) {
    if (formTheme.placeHolderColor != null) {
      return formTheme.placeHolderColor;
    }

    return null;
  }

  double? getPlaceholderFontSize(FormTheme formTheme) {
    if (formTheme.placeHolderFontSize != null) {
      return formTheme.placeHolderFontSize;
    }

    return null;
  }

  Color? getValueColor(FormTheme formTheme) {
    if (formTheme.valueColor != null) {
      return formTheme.valueColor;
    }

    return null;
  }

  double? getValueFontSize(FormTheme formTheme) {
    if (formTheme.valueFontSize != null) {
      return formTheme.valueFontSize;
    }
    return null;
  }

  FontWeight? getLabelFontWeight(FormTheme formTheme) {
    if (formTheme.labelFontWeight != null) {
      return formTheme.labelFontWeight;
    }
    return null;
  }

  double? getLabelFontSize(FormTheme formTheme) {
    if (formTheme.labelFontSize != null) {
      return formTheme.labelFontSize;
    }
    return null;
  }

  Color? getLabelColor(FormTheme formTheme) {
    if (formTheme.labelColor != null) {
      return formTheme.labelColor;
    }

    return null;
  }

  TextAlign getTextFieldTextAlign(FormTheme? formTheme) {
    if (formTheme == null || formTheme.textFieldTextAlign == null) {
      return TextAlign.start;
    }

    return formTheme.textFieldTextAlign!;
  }

  double getTextFieldPaddingTop(FormTheme? formTheme) {
    if (formTheme == null || formTheme.textFieldPaddingTop == null) {
      return 0.0;
    }

    return formTheme.textFieldPaddingTop!;
  }

  double getTextFieldPaddingEnd(FormTheme? formTheme) {
    if (formTheme == null || formTheme.textFieldPaddingEnd == null) {
      return 0.0;
    }

    return formTheme.textFieldPaddingEnd!;
  }

  double getTextFieldPaddingBottom(FormTheme? formTheme) {
    if (formTheme == null || formTheme.textFieldPaddingBottom == null) {
      return 0.0;
    }

    return formTheme.textFieldPaddingBottom!;
  }

  double getTextFieldPaddingStart(FormTheme? formTheme) {
    if (formTheme == null || formTheme.textFieldPaddingStart == null) {
      return 0.0;
    }

    return formTheme.textFieldPaddingStart!;
  }

  void nextFocus(FocusNode focusNode, bool isLastElement) {
    if (!isLastElement) {
      focusNode.nextFocus();
    }
  }
}
