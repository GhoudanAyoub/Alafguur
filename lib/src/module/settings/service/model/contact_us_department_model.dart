import 'package:json_annotation/json_annotation.dart';

part 'contact_us_department_model.g.dart';

@JsonSerializable()
class ContactUsDepartmentModel {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final String name;

  ContactUsDepartmentModel({
    required this.id,
    required this.name,
  });

  factory ContactUsDepartmentModel.fromJson(Map<String, dynamic> json) =>
      _$ContactUsDepartmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactUsDepartmentModelToJson(this);
}
