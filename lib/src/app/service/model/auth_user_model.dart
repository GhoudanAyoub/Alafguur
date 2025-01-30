import 'package:json_annotation/json_annotation.dart';

import '../../utility/converter_utility.dart';

part 'auth_user_model.g.dart';

@JsonSerializable()
class AuthUserModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String email;

  @JsonKey(defaultValue: false)
  final bool isAdmin;

  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserModelToJson(this);
}
