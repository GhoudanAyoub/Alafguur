import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../service/localization_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../style/form/text_form_element_widget_style.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../rtl_widget_mixin.dart';
import 'form_builder_widget.dart';
import 'form_element_widget_mixin.dart';

class TextFormElementWidget extends StatefulWidget
    with ModalWidgetMixin, RtlWidgetMixin, FormElementWidgetMixin {
  final FormElementModel formElementModel;
  final OnChangedValueCallback onChangedValueCallback;
  final OnFocusedCallback onFocusedCallback;
  final FormTheme? formTheme;
  final bool isLastElement;
  final bool isLastElementInGroup;
  final int defaultMinLines;
  final int defaultMaxLines;
  final bool defaultAutocorrect;

  const TextFormElementWidget({
    Key? key,
    required this.formElementModel,
    required this.onChangedValueCallback,
    required this.onFocusedCallback,
    this.formTheme,
    this.isLastElement = false,
    this.isLastElementInGroup = false,
    this.defaultMinLines = 1,
    this.defaultMaxLines = 5,
    this.defaultAutocorrect = false,
  }) : super(key: key);

  @override
  State createState() => _TextFormElementWidgetState();
}

class _TextFormElementWidgetState extends State<TextFormElementWidget> {
  late final TextEditingController _controller;
  late FocusNode textFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    textFocusNode = FocusNode();

    textFocusNode.addListener(() {
      widget.onFocusedCallback(
        widget.formElementModel.key,
        textFocusNode.hasFocus,
      );
    });
  }

  void dispose() {
    _controller.dispose();
    textFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // clear a value in the text controller
    if (widget.formElementModel.value == null) {
      _controller.clear();
    }

    // update a value in the text controller
    if (widget.formElementModel.value != null &&
        widget.formElementModel.value != _controller.text) {
      _controller.text = widget.formElementModel.value;
    }

    return Column(
      children: [
        Container(
          decoration: !widget.isLastElementInGroup
              ? textFormElementFormFieldDecorationContainer(widget.formTheme)
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: <Widget>[
                  // a label
                  if (widget.formElementModel.label != null)
                    textFormElementLabelTextContainer(
                      LocalizationService.of(context).t(
                        widget.formElementModel.label!,
                      ),
                      widget.isRtlMode(context),
                      widget.getLabelColor(widget.formTheme!),
                      widget.getLabelFontSize(widget.formTheme!),
                      widget.getLabelFontWeight(widget.formTheme!),
                    ),

                  // a text field
                  PlatformTextField(
                    focusNode: textFocusNode,
                    textAlign: widget.getTextFieldTextAlign(widget.formTheme),
                    autocorrect: _getAutocorrect(),
                    autofocus: false,
                    textInputAction: !widget.isLastElement
                        ? TextInputAction.next
                        : TextInputAction.done,
                    minLines:
                        widget.formElementModel.type == FormElements.textarea
                            ? _getMinLines()
                            : 1,
                    maxLines:
                        widget.formElementModel.type == FormElements.textarea
                            ? _getMaxLines()
                            : 1,
                    controller: _controller,
                    style: widget.getTextStyle(
                      widget.getValueColor(widget.formTheme!),
                      widget.getValueFontSize(widget.formTheme!),
                    ),
                    keyboardType: _getInputType(),
                    obscureText:
                        widget.formElementModel.type == FormElements.password,
                    onChanged: (value) => widget.onChangedValueCallback(
                      widget.formElementModel.key,
                      value,
                    ),
                    cupertino: (_, __) => CupertinoTextFieldData(
                      placeholderStyle: widget.getTextStyle(
                        widget.getPlaceholderColor(widget.formTheme!),
                        widget.getPlaceholderFontSize(widget.formTheme!),
                      ),
                      padding: textFormElementCupertinoTextFieldPadding(),
                      placeholder: widget.formElementModel.placeholder != null
                          ? LocalizationService.of(context).t(
                              widget.formElementModel.placeholder!,
                            )
                          : null,
                      decoration: textFormElementCupertinoTextFieldDecoration(),
                    ),
                    material: (_, __) => MaterialTextFieldData(
                      decoration: textFormElementMaterialTextFieldDecoration(
                        widget.formElementModel.placeholder != null
                            ? LocalizationService.of(context).t(
                                widget.formElementModel.placeholder!,
                              )
                            : null,
                        widget.getPlaceholderColor(widget.formTheme!),
                        widget.getPlaceholderFontSize(widget.formTheme!),
                      ),
                    ),
                  ).paddingDirectional(
                    top: widget.getTextFieldPaddingTop(widget.formTheme!),
                    start: widget.getTextFieldPaddingStart(widget.formTheme!),
                    bottom: widget.getTextFieldPaddingBottom(widget.formTheme!),
                    end: widget.getTextFieldPaddingEnd(widget.formTheme!),
                  ),
                ].toColumn(),
              ),

              // an error
              if (widget.isErrorAvailable(widget.formElementModel))
                widget.getErrorWidget(
                  widget.formElementModel,
                  context,
                ),
            ],
          ),
        ),
        // a loading bar
        if (widget.formElementModel.isValidationStarted == true)
          LoadingIndicatorWidget(),
      ],
    );
  }

  TextInputType _getInputType() {
    switch (widget.formElementModel.type) {
      case FormElements.email:
        return TextInputType.emailAddress;

      case FormElements.textarea:
        return TextInputType.multiline;

      case FormElements.url:
        return TextInputType.url;

      case FormElements.number:
        return TextInputType.number;

      default:
        return TextInputType.text;
    }
  }

  int? _getMinLines() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.min)) {
      return widget.formElementModel.params![FormElementParams.min];
    }

    return widget.defaultMinLines;
  }

  int? _getMaxLines() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.max)) {
      return widget.formElementModel.params![FormElementParams.max];
    }

    return widget.defaultMaxLines;
  }

  bool? _getAutocorrect() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!
            .containsKey(FormElementParams.autocorrect)) {
      return widget.formElementModel.params![FormElementParams.autocorrect];
    }

    return widget.defaultAutocorrect;
  }
}
