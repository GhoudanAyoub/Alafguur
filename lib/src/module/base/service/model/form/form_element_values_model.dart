import 'package:json_annotation/json_annotation.dart';

part 'form_element_values_model.g.dart';

@JsonSerializable()
class FormElementValuesModel {
  @JsonKey(required: true)
  final dynamic value;

  @JsonKey(required: true)
  final String title;

  FormElementValuesModel({
    required this.value,
    required this.title,
  });

  factory FormElementValuesModel.fromJson(Map<String, String> json) =>
      _$FormElementValuesModelFromJson(json);

  Map<String, dynamic> toJson() => _$FormElementValuesModelToJson(this);
}
