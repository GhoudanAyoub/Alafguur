import 'package:json_annotation/json_annotation.dart';

part 'user_gender_model.g.dart';

@JsonSerializable()
class UserGenderModel {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final String name;

  UserGenderModel({
    required this.id,
    required this.name,
  });

  factory UserGenderModel.fromJson(Map<String, dynamic> json) =>
      _$UserGenderModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserGenderModelToJson(this);
}
