import 'package:json_annotation/json_annotation.dart';

part 'email_valid_response.g.dart';

@JsonSerializable()
class EmailValidResponseResponse {
  @JsonKey(required: false)
  bool isEmailExists;

  EmailValidResponseResponse({
    required this.isEmailExists,
  });

  factory EmailValidResponseResponse.fromJson(Map<String, dynamic> json) =>
      _$EmailValidResponseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmailValidResponseResponseToJson(this);
}
