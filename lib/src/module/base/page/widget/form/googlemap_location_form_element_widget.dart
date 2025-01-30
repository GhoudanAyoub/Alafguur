import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sprintf/sprintf.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../state/form/google_location_form_element_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/form/googlemap_location_form_element_widget_style.dart';
import '../loading_indicator_widget.dart';
import '../loading_spinner_widget.dart';
import '../modal_widget_mixin.dart';
import '../rtl_widget_mixin.dart';
import '../search_field_widget.dart';
import 'form_builder_widget.dart';
import 'form_element_widget_mixin.dart';

class GoogleMapLocationFormElementWidget extends StatefulWidget
    with ModalWidgetMixin, RtlWidgetMixin, FormElementWidgetMixin {
  final FormElementModel formElementModel;
  final OnChangedValueCallback onChangedValueCallback;
  final OnFocusedCallback onFocusedCallback;
  final FormTheme? formTheme;
  final bool isLastElement;
  final bool isLastElementInGroup;
  final bool isExtendedView;

  const GoogleMapLocationFormElementWidget({
    Key? key,
    required this.formElementModel,
    required this.onChangedValueCallback,
    required this.onFocusedCallback,
    this.formTheme,
    this.isLastElement = false,
    this.isLastElementInGroup = false,
    this.isExtendedView = false,
  }) : super(key: key);

  @override
  _GoogleMapLocationFormElementWidgetState createState() =>
      _GoogleMapLocationFormElementWidgetState();
}

class _GoogleMapLocationFormElementWidgetState
    extends State<GoogleMapLocationFormElementWidget> {
  late final GoogleLocationFormElementState _state;

  late final FocusNode _selectFocusNode;

  final valueDistance = 'distance';
  final valueLocation = 'location';

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<GoogleLocationFormElementState>();
    _selectFocusNode = FocusNode();

    // init a distance value (only in in the extended view)
    if (widget.isExtendedView) {
      _state.distance = _getDistanceValue();
    }

    // init a location value
    if (_getLocationValue() != null) {
      _state.loadLocations(_getLocationValue()!);
    }
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
                ? googleMapLocationFormFieldDecorationContainer(
                    widget.formTheme)
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: googleMapLocationFormFieldContainer(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // a label
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            googleMapLocationFormFieldLabelTextContainer(
                              widget.getLabel(
                                widget.formElementModel,
                                context,
                              ),
                              widget.getLabelColor(widget.formTheme!),
                              widget.getLabelFontSize(widget.formTheme!),
                              widget.getLabelFontWeight(widget.formTheme!),
                            ),
                            if (widget.isExtendedView)
                              Observer(
                                builder: (_) =>
                                    googleMapLocationFormFieldDistanceValueTextContainer(
                                  _getDistanceDescription(),
                                ),
                              ),
                          ],
                        ),
                        // a distance slider
                        if (widget.isExtendedView) _getDistanceSlider(),
                        // a selected location
                        if (_getLocationDisplayableValue() != null)
                          _getLocationDisplayableValue()!,
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
          ).backgroundColor(transparentColor()).gestures(
                onTap: () => _showLocationPopup(context),
              ),
          // a loading bar
          if (widget.formElementModel.isValidationStarted == true)
            LoadingIndicatorWidget(),
        ],
      ),
    );
  }

  /// show a location popup window
  void _showLocationPopup(BuildContext context) {
    // focus the form element
    if (!_selectFocusNode.hasFocus) {
      _selectFocusNode.requestFocus();
    }

    showPlatformDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t(
          'choose_location_page_header',
        ),
        body: googleMapLocationFormFieldPopupContainer(
          Column(
            children: [
              // a search field
              googleMapLocationPopupSearchContainer(
                SearchFieldWidget(
                  onChangedValueCallback:
                      _onChangedLocationPopupSearchValueCallback(),
                  value: _state.locationKeyword,
                  backgroundColor:
                      AppSettingsService.themeCommonScaffoldLightColor,
                  placeholderColor:
                      AppSettingsService.themeCommonFormPlaceholderColor,
                  textColor: AppSettingsService.themeCommonTextColor,
                ),
              ),
              // a search result
              Container(
                child: Expanded(
                  child: Observer(builder: (_) {
                    if (_state.isPageLoading) return LoadingSpinnerWidget();

                    // list of suggested locations (with auto scroll)
                    return Material(
                      color: transparentColor(),
                      child: ListView.separated(
                        itemCount: _state.locations.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title:
                                googleMapLocationPopupSearchResultValueColorContainer(
                              Text(
                                '${_state.locations[index]}',
                              ),
                            ),
                            onTap: () =>
                                _closeLocationPopup(_state.locations[index]),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            googleMapLocationPopupSearchResultDividerContainer(),
                      ),
                    );
                  }),
                ),
              ),
              // a "keep empty" button
              Container(
                width: MediaQuery.of(context).size.width,
                child: googleMapLocationFormFieldPopupButtonContainer(
                  'keep_empty',
                  context,
                  () => _closeLocationPopup(null, clearData: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// the search field callback handler
  OnChangedSearchValueCallback _onChangedLocationPopupSearchValueCallback() {
    // load location suggestions
    return (String value) {
      _state.loadLocations(value);
    };
  }

  /// return a distance slider
  Widget _getDistanceSlider() {
    return Observer(
      builder: (_) => Material(
        color: transparentColor(),
        child: SliderTheme(
          data: googleMapLocationFormElementSliderThemeData(),
          child: Slider(
            min: _getDistanceMinValue(),
            max: _getDistanceMaxValue(),
            onChanged: (double value) {
              // focus the form element
              if (!_selectFocusNode.hasFocus) {
                _selectFocusNode.requestFocus();
              }

              // save the selected distance in the state
              _state.distance = value;
            },
            onChangeEnd: (double value) => _returnData(),
            value: _state.distance,
          ),
        ),
      ),
    );
  }

  Widget _getDistanceDescription() {
    if (widget.isRtlMode(context)) {
      return googleMapLocationFormElementSliderValueContainer(
        Text(sprintf('%s %s %s', [
          LocalizationService.of(context).t('from'),
          LocalizationService.of(context).t(_getDistanceUnitValue()!),
          _state.distance.round().toString(),
        ])),
      );
    }

    return googleMapLocationFormElementSliderValueContainer(
      Text(
        sprintf(
          '%s %s %s',
          [
            _state.distance.round().toString(),
            LocalizationService.of(context).t(_getDistanceUnitValue()!),
            LocalizationService.of(context).t('from')
          ],
        ),
      ),
    );
  }

  /// get location value
  String? _getLocationValue() {
    if (widget.isExtendedView) {
      if (widget.formElementModel.value != null &&
          widget.formElementModel.value.containsKey(valueLocation)) {
        return widget.formElementModel.value[valueLocation];
      }

      return null;
    }

    return widget.formElementModel.value;
  }

  /// get a distance value
  double _getDistanceValue() {
    if (widget.formElementModel.value != null &&
        widget.formElementModel.value.containsKey(valueDistance)) {
      return double.parse(
        widget.formElementModel.value[valueDistance].toString(),
      );
    }

    throw ArgumentError('The distance value is not defined');
  }

  /// get a distance unit
  String? _getDistanceUnitValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.unit)) {
      return widget.formElementModel.params![FormElementParams.unit];
    }

    throw ArgumentError('The distance unit is not defined');
  }

  /// get a min distance value from the element's params
  double _getDistanceMinValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.min)) {
      return double.parse(
        widget.formElementModel.params![FormElementParams.min].toString(),
      );
    }

    throw ArgumentError('The distance min value is not defined');
  }

  /// get a max distance value from the element's params
  double _getDistanceMaxValue() {
    if (widget.formElementModel.params != null &&
        widget.formElementModel.params!.containsKey(FormElementParams.max)) {
      return double.parse(
        widget.formElementModel.params![FormElementParams.max].toString(),
      );
    }

    throw ArgumentError('The distance max value is not defined');
  }

  /// return either a selected location or a placeholder
  Widget? _getLocationDisplayableValue() {
    final String? currentLocation = _getLocationValue();

    if (currentLocation != null && currentLocation.isNotEmpty) {
      return googleMapLocationFormFieldValueTextContainer(
        currentLocation,
        widget.getValueColor(widget.formTheme!),
        widget.getValueFontSize(widget.formTheme!),
      );
    }

    if (widget.formElementModel.placeholder != null) {
      return googleMapLocationFormFieldValueTextContainer(
        LocalizationService.of(context).t(
          widget.formElementModel.placeholder!,
        ),
        widget.getPlaceholderColor(widget.formTheme!),
        widget.getPlaceholderFontSize(widget.formTheme!),
      );
    }

    return null;
  }

  /// close the location popup and return data back
  void _closeLocationPopup(String? location, {bool clearData = false}) {
    _state.locationKeyword = location ?? '';

    if (clearData) {
      _state.clearLocations();
    }

    _returnData();

    // close the location popup and set the focus on a next element
    Navigator.pop(context);
    widget.nextFocus(_selectFocusNode, widget.isLastElement);
  }

  void _returnData() {
    if (widget.isExtendedView) {
      widget.onChangedValueCallback(
        widget.formElementModel.key,
        {
          valueDistance: _state.distance.round(),
          valueLocation: _state.locationKeyword,
        },
      );

      return;
    }

    widget.onChangedValueCallback(
      widget.formElementModel.key,
      _state.locationKeyword,
    );
  }
}
