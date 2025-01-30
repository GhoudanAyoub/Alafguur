import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../state/form/form_builder_state.dart';
import '../../style/form/form_builder_widget_style.dart';
import 'date_form_element_widget.dart';
import 'googlemap_location_form_element_widget.dart';
import 'range_form_element_widget.dart';
import 'select_form_element_widget.dart';
import 'single_choice_form_element_widget.dart';
import 'text_form_element_widget.dart';

typedef FormRendererCallback = Widget? Function(
  Map<String, Widget> presentationMap,
  Map<String, FormElementModel> elementMap,
  BuildContext context,
);

typedef OnChangedValueCallback = void Function(String key, dynamic value);
typedef OnFocusedCallback = void Function(String key, bool isFocused);

class FormTheme {
  final Color? labelColor;
  final Color? textColor;
  final Color? placeHolderColor;
  final Color? valueColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? valueFontSize;
  final FontWeight? labelFontWeight;
  final double? labelFontSize;
  final double? placeHolderFontSize;
  final TextAlign? textFieldTextAlign;
  final double? textFieldPaddingTop;
  final double? textFieldPaddingEnd;
  final double? textFieldPaddingBottom;
  final double? textFieldPaddingStart;

  FormTheme({
    this.labelColor,
    this.textColor,
    this.placeHolderColor,
    this.valueColor,
    this.borderColor,
    this.borderWidth,
    this.valueFontSize,
    this.labelFontWeight,
    this.labelFontSize,
    this.placeHolderFontSize,
    this.textFieldTextAlign,
    this.textFieldPaddingTop,
    this.textFieldPaddingEnd,
    this.textFieldPaddingBottom,
    this.textFieldPaddingStart,
  });
}

class FormBuilderWidget extends StatefulWidget {
  final FormBuilderState state;

  FormBuilderWidget({
    Key? key,
    required this.state,
  }) : super(key: key) {
    // register a default form theme
    state.formTheme = FormTheme(
      labelColor: AppSettingsService.themeCommonFormLabelColor,
      textColor: AppSettingsService.themeCommonFormTextColor,
      placeHolderColor: AppSettingsService.themeCommonFormPlaceholderColor,
      valueColor: AppSettingsService.themeCommonFormValueColor,
      borderColor: AppSettingsService.themeCommonDividerColor,
      borderWidth: 1,
      valueFontSize: 14,
      labelFontSize: 17,
      labelFontWeight: FontWeight.w400,
      placeHolderFontSize: 14,
    );

    // register a default form renderer
    state.formRendererCallback = defaultFormRenderer();
  }

  /// register a custom form theme
  void registerFormTheme(FormTheme formTheme) {
    state.formTheme = formTheme;
  }

  /// register a form renderer
  void registerFormRenderer(FormRendererCallback renderer) {
    state.formRendererCallback = renderer;
  }

  /// unregister all form elements
  void unregisterAllFormElements() {
    state.elementsMap.clear();
  }

  /// register form elements
  void registerFormElements(List<FormElementModel> elements) {
    // clone received elements (to prevent mutation in the original elements)
    elements.forEach((element) {
      state.elementsMap[element.key] = state.cloneElement(element);
    });
  }

  /// register form on changed callback
  void registerFormOnChangedCallback(OnChangedValueCallback callback) {
    state.formOnChangedCallback = callback;
  }

  /// register form on focused callback
  void registerFormOnFocusedCallback(OnFocusedCallback callback) {
    state.formOnFocusedCallback = callback;
  }

  /// reset form values
  void reset() => state.reset();

  void updateElementValue(String key, dynamic value) =>
      state.updateElementValue(key, value);

  /// check if the form is valid or not
  Future<bool> isFormValid() => state.isFormValid();

  /// Get key -> element value map of the form elements. If an [Iterable] of
  /// keys is passed to the [keys] parameter, only the form elements identified
  /// by the given keys will be returned.
  Map<String, dynamic> getFormValues({
    Iterable<String>? keys,
  }) =>
      _filterFormElementsByKeys(keys: keys).map(
        (key, element) => MapEntry(key, element!.value),
      );

  /// Get a list of form elements. If an [Iterable] of keys is passed to the
  /// [keys] parameter, only the form elements identified by the given keys will
  /// be returned.
  List<FormElementModel?> getFormElementsList({
    Iterable<String>? keys,
  }) =>
      _filterFormElementsByKeys(keys: keys).values.toList();

  /// Get key -> element map of the form elements. If an [Iterable] of keys is
  /// passed to the [keys] parameter, only the form elements identified by the
  /// given keys will be returned.
  Map<String, FormElementModel?> _filterFormElementsByKeys({
    Iterable<String>? keys,
  }) {
    return keys == null
        ? state.elementsMap
        : state.elementsMap.keys.fold(
            {},
            (prev, key) => keys.contains(key)
                ? {
                    ...prev,
                    key: state.elementsMap[key],
                  }
                : prev,
          );
  }

  /// Get a form element by its [key].
  FormElementModel? operator [](String key) {
    return state.elementsMap[key];
  }

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilderWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.state.formRendererCallback == null) {
      throw ArgumentError('The form renderer is not defined');
    }
    return Observer(
      builder: (BuildContext context) {
        return FocusScope(
          child: widget.state.formRendererCallback!(
            _getFormPresentationElements(),
            {
              ...widget.state.elementsMap,
            },
            context,
          )!,
        );
      },
    );
  }

  /// return a list of presentation elements based on form elements
  Map<String, Widget> _getFormPresentationElements() {
    // convert an elements map into a list
    final List<FormElementModel> elementList = widget.state.elementsMap.entries
        .map((element) => element.value)
        .toList();

    final int elementsCount = elementList.length - 1;

    Map<String, Widget> elements = {};
    int index = 0;

    elementList.forEach((formElementModel) {
      final FormElementModel? nextElementModel =
          elementList.asMap().containsKey(index + 1)
              ? elementList[index + 1]
              : null;
      final bool isLastElementInGroup = nextElementModel == null ||
          nextElementModel.group != formElementModel.group;

      switch (formElementModel.type) {
        case FormElements.checkbox:
          elements[formElementModel.key] = SingleChoiceFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        case FormElements.age:
        case FormElements.birthDate:
        case FormElements.date:
          elements[formElementModel.key] = DateFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        case FormElements.extendedGoogleMapLocation:
        case FormElements.googleMapLocation:
          elements[formElementModel.key] = GoogleMapLocationFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isExtendedView:
                formElementModel.type == FormElements.extendedGoogleMapLocation,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        case FormElements.range:
          elements[formElementModel.key] = RangeFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        case FormElements.radio:
        case FormElements.select:
        case FormElements.fastSelect:
          elements[formElementModel.key] = SelectFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            isMultiple: false,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        case FormElements.multiSelect:
        case FormElements.multiCheckbox:
          elements[formElementModel.key] = SelectFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            isMultiple: true,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        case FormElements.text:
        case FormElements.password:
        case FormElements.email:
        case FormElements.number:
        case FormElements.textarea:
        case FormElements.url:
          elements[formElementModel.key] = TextFormElementWidget(
            onChangedValueCallback: _onChangedValueCallback,
            onFocusedCallback: _onFocusedCallback,
            formElementModel: formElementModel,
            formTheme: widget.state.formTheme,
            isLastElement: index == elementsCount,
            isLastElementInGroup: isLastElementInGroup,
          );
          break;
        default:
      }
      index++;
    });

    return elements;
  }

  /// update a form element's value in the state and trigger a callback
  OnChangedValueCallback? _onChangedValueCallback(
    String key,
    dynamic value,
  ) {
    widget.state.updateElementValue(key, value);
    widget.state.formOnChangedCallback?.call(key, value);
    return null;
  }

  OnFocusedCallback? _onFocusedCallback(
    String key,
    bool isFocused,
  ) {
    widget.state.formOnFocusedCallback?.call(key, isFocused);
    return null;
  }
}
