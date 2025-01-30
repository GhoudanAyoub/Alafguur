import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../../service/model/form/form_element_values_model.dart';
import '../../state/form/select_form_element_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/form/select_form_element_widget_style.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../rtl_widget_mixin.dart';
import 'form_builder_widget.dart';
import 'form_element_widget_mixin.dart';

class SelectFormElementWidget extends StatefulWidget
    with ModalWidgetMixin, RtlWidgetMixin, FormElementWidgetMixin {
  final FormElementModel formElementModel;
  final OnChangedValueCallback onChangedValueCallback;
  final OnFocusedCallback onFocusedCallback;
  final bool isMultiple;
  final FormTheme? formTheme;
  final bool isLastElement;
  final bool isLastElementInGroup;

  const SelectFormElementWidget({
    Key? key,
    required this.formElementModel,
    required this.onChangedValueCallback,
    required this.onFocusedCallback,
    required this.isMultiple,
    this.formTheme,
    this.isLastElement = false,
    this.isLastElementInGroup = false,
  }) : super(key: key);

  @override
  State createState() => _SelectFormElementWidgetState();
}

class _SelectFormElementWidgetState extends State<SelectFormElementWidget> {
  late final SelectFormElementState _state;
  late final FocusNode _selectFocusNode;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<SelectFormElementState>();
    _selectFocusNode = FocusNode();

    // init values
    _initValues();
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
                ? selectFormElementDecorationContainer(widget.formTheme)
                : null,
            child: selectFormElementContainer(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // a label
                        selectFormElementLabelTextContainer(
                          widget.getLabel(
                            widget.formElementModel,
                            context,
                          ),
                          widget.getLabelColor(widget.formTheme!),
                          widget.getLabelFontSize(widget.formTheme!),
                          widget.getLabelFontWeight(widget.formTheme!),
                        ),
                        // a selected value
                        if (_getDisplayableValue() != null)
                          _getDisplayableValue()!,
                      ],
                    ),
                  ),
                  Icon(
                    Icons.navigate_next,
                    color: widget.formElementModel.value != null
                        ? widget.getValueColor(widget.formTheme!)
                        : widget.getPlaceholderColor(widget.formTheme!),
                  ),
                  if (widget.isErrorAvailable(widget.formElementModel))
                    widget.getErrorWidget(
                      widget.formElementModel,
                      context,
                    ),
                ],
              ),
            ),
          )
              .backgroundColor(transparentColor())
              .gestures(onTap: () => _showValuesPopup(context)),
          if (widget.formElementModel.isValidationStarted == true)
            LoadingIndicatorWidget(),
        ],
      ),
    );
  }

  String _getValuesString() {
    List selectedValues = [];

    // collect and translate selected values
    widget.formElementModel.values!.forEach((option) {
      if (_state.values.contains(option.value)) {
        selectedValues.add(
          LocalizationService.of(context).t(option.title),
        );
      }
    });

    return selectedValues.join(', ');
  }

  /// show a popup window with form element values
  void _showValuesPopup(BuildContext context) {
    // focus the form element
    if (!_selectFocusNode.hasFocus) {
      _selectFocusNode.requestFocus();
    }

    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: widget.formElementModel.label != null
            ? selectFormElementPopupLabelContainer(
                LocalizationService.of(context).t(
                  widget.formElementModel.label ?? '',
                ),
              )
            : null,
        material: (_, __) => MaterialAlertDialogData(
          scrollable: true,
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
        ),
        content: selectFormDialogContentWrapperContainer(
          Material(
            color: transparentColor(),
            child: Observer(
              builder: (_) => widget.formElementModel.values!
                  .map((option) {
                    return _generatePopupSelector(option);
                  })
                  .toList()
                  .toColumn(),
            ),
          ),
        ),
        actions: <Widget>[
          // cancel
          PlatformDialogAction(
            onPressed: () {
              // reset values
              _state.clearValues();
              _initValues();
              Navigator.pop(context);
            },
            material: (_, __) => MaterialDialogActionData(
              child: Text(
                LocalizationService.of(context).t('cancel').toUpperCase(),
              ),
            ),
            cupertino: (_, __) => CupertinoDialogActionData(
              child: Text(
                LocalizationService.of(context).t('cancel'),
              ),
              textStyle: TextStyle(
                color: AppSettingsService.themeCommonAccentColor,
              ),
            ),
          ),
          // ok
          PlatformDialogAction(
            onPressed: () {
              widget.onChangedValueCallback(
                widget.formElementModel.key,
                [..._state.values],
              );

              Navigator.pop(context);
              widget.nextFocus(_selectFocusNode, widget.isLastElement);
            },
            material: (_, __) => MaterialDialogActionData(
              child: Text(
                LocalizationService.of(context).t('ok').toUpperCase(),
              ),
            ),
            cupertino: (_, __) => CupertinoDialogActionData(
              child: Text(
                LocalizationService.of(context).t('ok'),
              ).fontWeight(FontWeight.bold),
              textStyle: TextStyle(
                color: AppSettingsService.themeCommonAccentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _generatePopupSelector(FormElementValuesModel option) {
    if (widget.isMultiple) {
      return Theme(
        data: ThemeData(
          unselectedWidgetColor: AppSettingsService.isDarkMode
              ? AppSettingsService.themeCommonTextColor
              : AppSettingsService.themeCommonAlertPassiveIconColor,
        ),
        child: ListTileTheme(
          textColor: AppSettingsService.themeCommonTextColor,
          contentPadding: EdgeInsets.all(0),
          horizontalTitleGap: 0,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.all(0),
            activeColor: AppSettingsService.themeCommonAccentColor,
            title: Text(LocalizationService.of(context).t(
              option.title,
            )),
            value: _state.values.contains(option.value),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? isChecked) {
              isChecked!
                  ? _state.addValue(option.value)
                  : _state.removeValue(option.value);
            },
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        unselectedWidgetColor: AppSettingsService.isDarkMode
            ? AppSettingsService.themeCommonTextColor
            : AppSettingsService.themeCommonAlertPassiveIconColor,
      ),
      child: ListTileTheme(
        textColor: AppSettingsService.themeCommonTextColor,
        contentPadding: EdgeInsets.all(0),
        horizontalTitleGap: 0,
        child: RadioListTile(
          contentPadding: EdgeInsets.all(0),
          activeColor: AppSettingsService.themeCommonAccentColor,
          title: Text(
            LocalizationService.of(context).t(
              option.title,
            ),
          ),
          toggleable: true,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (dynamic value) {
            _state.setValue(value);
          },
          value: option.value,
          groupValue: _state.values.isNotEmpty ? _state.values[0] : null,
        ),
      ),
    );
  }

  void _initValues() {
    if (widget.formElementModel.value is List) {
      widget.formElementModel.value.forEach(
        (value) => _state.addValue(value),
      );
    }
  }

  /// return either a selected value or a placeholder
  Widget? _getDisplayableValue() {
    if (widget.formElementModel.value != null &&
        widget.formElementModel.value.isNotEmpty) {
      return selectFormElementSelectedValuesContainer(
        context,
        _getValuesString(),
        widget.getValueColor(widget.formTheme!),
        widget.getValueFontSize(widget.formTheme!),
      );
    }

    if (widget.formElementModel.placeholder != null) {
      return selectFormElementSelectedValuesContainer(
        context,
        LocalizationService.of(context).t(
          widget.formElementModel.placeholder!,
        ),
        widget.getPlaceholderColor(widget.formTheme!),
        widget.getPlaceholderFontSize(widget.formTheme!),
      );
    }

    return null;
  }
}
