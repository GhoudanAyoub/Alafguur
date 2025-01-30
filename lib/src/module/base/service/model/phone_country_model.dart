import 'package:json_annotation/json_annotation.dart';

part 'phone_country_model.g.dart';

@JsonSerializable()
class PhoneCountryModel {
  @JsonKey(required: true)
  final String title;

  @JsonKey(required: true)
  final String phoneCode;

  PhoneCountryModel({
    required this.title,
    required this.phoneCode,
  });

  factory PhoneCountryModel.fromJson(Map<String, dynamic> json) =>
      _$PhoneCountryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneCountryModelToJson(this);
}
