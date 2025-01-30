import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'user_phone_model.g.dart';

@JsonSerializable()
class UserPhoneModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int userId;

  final String? number;

  final String? code;

  final String? countryCode;

  @JsonKey(fromJson: ConverterUtility.dynamicToInt)
  final int? isVeryfied;

  UserPhoneModel({
    required this.userId,
    this.number,
    this.code,
    this.countryCode,
    this.isVeryfied,
  });

  factory UserPhoneModel.fromJson(Map<String, dynamic> json) =>
      _$UserPhoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPhoneModelToJson(this);
}
