import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../style/form/single_choice_form_element_widget_style.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../rtl_widget_mixin.dart';
import 'form_builder_widget.dart';
import 'form_element_widget_mixin.dart';

class SingleChoiceFormElementWidget extends StatefulWidget
    with ModalWidgetMixin, RtlWidgetMixin, FormElementWidgetMixin {
  final FormElementModel formElementModel;
  final OnChangedValueCallback onChangedValueCallback;
  final OnFocusedCallback onFocusedCallback;
  final FormTheme? formTheme;
  final bool isLastElement;
  final bool isLastElementInGroup;

  const SingleChoiceFormElementWidget({
    Key? key,
    required this.formElementModel,
    required this.onChangedValueCallback,
    required this.onFocusedCallback,
    this.formTheme,
    this.isLastElement = false,
    this.isLastElementInGroup = false,
  }) : super(key: key);

  @override
  _SingleChoiceFormElementWidgetState createState() =>
      _SingleChoiceFormElementWidgetState();
}

class _SingleChoiceFormElementWidgetState
    extends State<SingleChoiceFormElementWidget> {
  late final FocusNode _selectFocusNode;

  @override
  void initState() {
    super.initState();
    _selectFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _selectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _selectFocusNode,
      child: Column(
        children: [
          Container(
            decoration: !widget.isLastElementInGroup
                ? singleChoiceFormFieldDecorationContainer(widget.formTheme)
                : null,
            child: singleChoiceFormFieldContainer(
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // a label
                  Expanded(
                    child: singleChoiceFormFieldLabelTextContainer(
                      widget.getLabel(
                        widget.formElementModel,
                        context,
                      ),
                      widget.getLabelColor(widget.formTheme!),
                      widget.getLabelFontSize(widget.formTheme!),
                      widget.getLabelFontWeight(widget.formTheme!),
                    ),
                  ),
                  // "yes/no" switcher
                  PlatformSwitch(
                    cupertino: (_, __) => CupertinoSwitchData(
                      activeColor: AppSettingsService.themeCommonAccentColor,
                    ),
                    onChanged: (bool value) {
                      // focus the form element
                      if (!_selectFocusNode.hasFocus) {
                        _selectFocusNode.requestFocus();
                      }
                      widget.onChangedValueCallback(
                        widget.formElementModel.key,
                        value,
                      );
                    },
                    value: widget.formElementModel.value != null
                        ? widget.formElementModel.value
                        : false,
                  ),
                  // an error
                  if (widget.isErrorAvailable(widget.formElementModel))
                    widget.getErrorWidget(
                      widget.formElementModel,
                      context,
                    )
                ],
              ),
            ),
          ),
          // a loading bar
          if (widget.formElementModel.isValidationStarted == true)
            LoadingIndicatorWidget(),
        ],
      ),
    );
  }
}
