import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../state/form/date_form_element_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/form/date_form_element_widget_style.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../rtl_widget_mixin.dart';
import 'form_builder_widget.dart';
import 'form_element_widget_mixin.dart';

class DateFormElementWidget extends StatefulWidget
    with ModalWidgetMixin, RtlWidgetMixin, FormElementWidgetMixin {
  final FormElementModel formElementModel;
  final OnChangedValueCallback onChangedValueCallback;
  final OnFocusedCallback onFocusedCallback;
  final FormTheme? formTheme;
  final String dateFormat;
  final bool isLastElement;
  final bool isLastElementInGroup;

  const DateFormElementWidget({
    Key? key,
    required this.formElementModel,
    required this.onChangedValueCallback,
    required this.onFocusedCallback,
    this.formTheme,
    this.isLastElement = false,
    this.isLastElementInGroup = false,
    this.dateFormat = 'yyyy-MM-dd',
  }) : super(key: key);

  @override
  _DateFormElementWidgetState createState() => _DateFormElementWidgetState();
}

class _DateFormElementWidgetState extends State<DateFormElementWidget> {
  late final DateFormElementState _state;
  late final FocusNode _selectFocusNode;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<DateFormElementState>();
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
                ? dateFormElementDecorationContainer(widget.formTheme)
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: dateFormElementContainer(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // a label
                        dateFormElementLabelTextContainer(
                          widget.getLabel(
                            widget.formElementModel,
                            context,
                          ),
                          widget.getLabelColor(widget.formTheme!),
                          widget.getLabelFontSize(widget.formTheme!),
                          widget.getLabelFontWeight(widget.formTheme!),
                        ),
                        // a selected date
                        if (_getDisplayableValue() != null)
                          _getDisplayableValue()!,
                      ],
                    ),
                  ),
                ),
                // an error
                if (widget.isErrorAvailable(widget.formElementModel))
                  widget.getErrorWidget(
                    widget.formElementModel,
                    context,
                  )
              ],
            ),
          ).gestures(onTap: () => _showCalendar()),
          // a loading bar
          if (widget.formElementModel.isValidationStarted == true)
            LoadingIndicatorWidget(),
        ],
      ),
    );
  }

  /// show a platform specified calendar and set focus
  void _showCalendar() {
    // focus the form element
    if (!_selectFocusNode.hasFocus) {
      _selectFocusNode.requestFocus();
    }

    Theme.of(context).platform == TargetPlatform.iOS
        ? _showCupertinoCalendar()
        : _showMaterialCalendar();
  }

  /// show a cupertino designed calendar
  void _showCupertinoCalendar() {
    // init a default value
    _state.date = _getInitialValue();

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (BuildContext builder) {
          return scaffoldContainer(
            context,
            showHeaderBackButton: false,
            header: widget.getLabel(widget.formElementModel, context),
            headerActions: [
              // clear button
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppSettingsService.themeCommonAccentColor,
                ),
                onPressed: () {
                  widget.onChangedValueCallback(
                    widget.formElementModel.key,
                    null,
                  );
                  Navigator.pop(context);
                },
                child: Text(LocalizationService.of(context).t('clear')),
              ),
              // ok button
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppSettingsService.themeCommonAccentColor,
                ),
                onPressed: () {
                  widget.onChangedValueCallback(
                    widget.formElementModel.key,
                    DateFormat(widget.dateFormat).format(_state.date!),
                  );
                  Navigator.pop(context);
                  widget.nextFocus(_selectFocusNode, widget.isLastElement);
                },
                child: Text(LocalizationService.of(context).t('ok')),
              ),
            ],
            body: CupertinoDatePicker(
              initialDateTime: _getInitialValue(),
              onDateTimeChanged: (DateTime newDate) {
                _state.date = newDate;
              },
              minimumYear: _getMinDateValue().year,
              maximumYear: _getMaxDateValue().year,
              mode: CupertinoDatePickerMode.date,
            ),
          );
        });
  }

  /// show a material designed calendar
  _showMaterialCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _getInitialValue(),
      firstDate: _getMinDateValue(),
      cancelText: LocalizationService.of(context).t('clear'),
      helpText: widget.getLabel(widget.formElementModel, context),
      lastDate: _getMaxDateValue(),
    );

    // return either a selected date or a null
    if (picked != null) {
      widget.onChangedValueCallback(
        widget.formElementModel.key,
        DateFormat(widget.dateFormat).format(picked),
      );
      widget.nextFocus(_selectFocusNode, widget.isLastElement);

      return;
    }

    widget.onChangedValueCallback(
      widget.formElementModel.key,
      null,
    );
  }

  /// return either a selected date or a placeholder
  Widget? _getDisplayableValue() {
    if (widget.formElementModel.value != null) {
      String dateTimePreview =
          DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
              .format(DateTime.parse(widget.formElementModel.value));

      return dateFormElementValueTextContainer(
        dateTimePreview.toString(),
        widget.getValueColor(widget.formTheme!),
        widget.getValueFontSize(widget.formTheme!),
      );
    }

    if (widget.formElementModel.placeholder != null) {
      return dateFormElementValueTextContainer(
        LocalizationService.of(context).t(
          widget.formElementModel.placeholder ?? '',
        ),
        widget.getPlaceholderColor(widget.formTheme!),
        widget.getPlaceholderFontSize(widget.formTheme!),
      );
    }

    return null;
  }

  DateTime _getInitialValue() {
    if (widget.formElementModel.value != null) {
      return DateTime.parse(widget.formElementModel.value);
    }

    return _getMaxDateValue();
  }

  DateTime _getMinDateValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!
            .containsKey(FormElementParams.minDate)) {
      return DateTime(
          widget.formElementModel.params![FormElementParams.minDate]);
    }

    // default date is 100 years before
    return DateTime.now().subtract(Duration(days: 360 * 100));
  }

  DateTime _getMaxDateValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!
            .containsKey(FormElementParams.maxDate)) {
      return DateTime(
          widget.formElementModel.params![FormElementParams.maxDate]);
    }

    // default date is current date
    return DateTime.now();
  }
}
