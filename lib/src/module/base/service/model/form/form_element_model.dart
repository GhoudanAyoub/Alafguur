import 'package:json_annotation/json_annotation.dart';

import 'form_async_validator_model.dart';
import 'form_element_values_model.dart';
import 'form_validator_model.dart';

part 'form_element_model.g.dart';

/// Available form element types.
class FormElements {
  static const text = 'text';
  static const email = 'email';
  static const url = 'url';
  static const number = 'number';
  static const password = 'password';
  static const textarea = 'textarea';
  static const radio = 'radio';
  static const select = 'select';
  static const fastSelect = 'fselect';
  static const multiSelect = 'multiselect';
  static const checkbox = 'checkbox';
  static const multiCheckbox = 'multicheckbox';
  static const range = 'range';
  static const googleMapLocation = 'googlemap_location';
  static const extendedGoogleMapLocation = 'extended_googlemap_location';
  static const age = 'age';
  static const birthDate = 'birthdate';
  static const date = 'date';
}

/// Form element parameters.
class FormElementParams {
  static const min = 'min';
  static const max = 'max';
  static const step = 'step';
  static const unit = 'unit';
  static const minDate = 'minDate';
  static const maxDate = 'maxDate';
  static const autocorrect = 'autocorrect';
}

@JsonSerializable(explicitToJson: true)
class FormElementModel {
  @JsonKey(required: true)
  final String key;

  @JsonKey(required: true)
  final String type;

  final String? label;

  final String? placeholder;

  final List<FormElementValuesModel>? values;

  String? group;

  final Map<String, dynamic>? params;

  List<FormValidatorModel>? validators;

  @JsonKey(name: 'async_validators')
  List<FormAsyncValidatorModel>? asyncValidators;

  dynamic value;

  @JsonKey(name: 'is_valid')
  bool? isValid;

  @JsonKey(name: 'is_validation_started')
  bool? isValidationStarted;

  @JsonKey(name: 'error_message')
  String? errorMessage;

  @JsonKey(name: 'display_validation_error', defaultValue: true)
  bool displayValidationError;

  FormElementModel({
    required this.key,
    required this.type,
    this.label,
    this.placeholder,
    this.value,
    this.values,
    this.group,
    this.params,
    this.validators,
    this.asyncValidators,
    this.displayValidationError = true,
  });

  factory FormElementModel.fromJson(Map<String, dynamic> json) {
    if (json['params'] is! Map) {
      json['params'] = <String, dynamic>{};
    }

    return _$FormElementModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FormElementModelToJson(this);
}
