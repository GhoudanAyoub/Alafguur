import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

import '../../../service/model/form/form_element_model.dart';
import '../../style/common_widget_style.dart';
import '../../style/form/range_form_element_widget_style.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../rtl_widget_mixin.dart';
import 'form_builder_widget.dart';
import 'form_element_widget_mixin.dart';

class RangeFormElementWidget extends StatefulWidget
    with ModalWidgetMixin, RtlWidgetMixin, FormElementWidgetMixin {
  final FormElementModel formElementModel;
  final OnChangedValueCallback onChangedValueCallback;
  final OnFocusedCallback onFocusedCallback;
  final FormTheme? formTheme;
  final bool isLastElement;
  final bool isLastElementInGroup;

  const RangeFormElementWidget({
    Key? key,
    required this.formElementModel,
    required this.onChangedValueCallback,
    required this.onFocusedCallback,
    this.formTheme,
    this.isLastElement = false,
    this.isLastElementInGroup = false,
  }) : super(key: key);

  @override
  _RangeFormElementWidgetState createState() => _RangeFormElementWidgetState();
}

class _RangeFormElementWidgetState extends State<RangeFormElementWidget> {
  late RangeValues _currentRangeValues;
  late final FocusNode _selectFocusNode;

  final valueLower = 'lower';
  final valueUpper = 'upper';

  @override
  void initState() {
    super.initState();

    _currentRangeValues = RangeValues(
      _getLowerValue(),
      _getUpperValue(),
    );

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
                ? rangeFormElementDecorationContainer(widget.formTheme)
                : null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    rangeFormElementLabelTextContainer(
                      widget.getLabel(
                        widget.formElementModel,
                        context,
                      ),
                      widget.getLabelColor(widget.formTheme!),
                      widget.getLabelFontSize(widget.formTheme!),
                      widget.getLabelFontWeight(widget.formTheme!),
                    ),
                    rangeFormElementValuesLabelTextContainer(
                      sprintf('%s-%s', _getCurrentRangeValues()),
                      widget.getValueColor(widget.formTheme!),
                      widget.getValueFontSize(widget.formTheme!),
                    ),
                  ],
                ),
                Material(
                  color: transparentColor(),
                  child: SliderTheme(
                    data: rangeFormElementSliderThemeData(),
                    child: rangeFormElementRangeContainer(
                      RangeSlider(
                        values: _currentRangeValues,
                        min: _getRangePossibleLowerValue(),
                        max: _getRangePossibleUpperValue(),
                        divisions: null,
                        onChangeEnd: (RangeValues values) {
                          widget.onChangedValueCallback(
                            widget.formElementModel.key,
                            {
                              valueLower: _currentRangeValues.start.round(),
                              valueUpper: _currentRangeValues.end.round()
                            },
                          );
                        },
                        onChanged: (RangeValues values) {
                          // focus the form element
                          if (!_selectFocusNode.hasFocus) {
                            _selectFocusNode.requestFocus();
                          }
                          setState(() {
                            _currentRangeValues = values;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.formElementModel.isValidationStarted == true)
            LoadingIndicatorWidget(),
        ],
      ),
    );
  }

  List _getCurrentRangeValues() {
    if (widget.isRtlMode(context)) {
      return [
        _currentRangeValues.end.round().toString(),
        _currentRangeValues.start.round().toString()
      ];
    }

    return [
      _currentRangeValues.start.round().toString(),
      _currentRangeValues.end.round().toString()
    ];
  }

  double _getLowerValue() {
    if (widget.formElementModel.value != null &&
        widget.formElementModel.value.containsKey(valueLower)) {
      return double.parse(widget.formElementModel.value[valueLower].toString());
    }

    throw ArgumentError('The initial lower value is not defined');
  }

  double _getRangePossibleLowerValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.min)) {
      return double.parse(
          widget.formElementModel.params![FormElementParams.min].toString());
    }

    throw ArgumentError('The range min value is not defined');
  }

  double _getUpperValue() {
    if (widget.formElementModel.value != null &&
        widget.formElementModel.value.containsKey(valueUpper)) {
      return double.parse(widget.formElementModel.value[valueUpper].toString());
    }

    throw ArgumentError('The initial upper value is not defined');
  }

  double _getRangePossibleUpperValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.max)) {
      return double.parse(
          widget.formElementModel.params![FormElementParams.max].toString());
    }

    throw ArgumentError('The range max value is not defined');
  }
}
