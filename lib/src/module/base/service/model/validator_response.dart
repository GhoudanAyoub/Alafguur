import 'package:json_annotation/json_annotation.dart';

part 'validator_response.g.dart';

@JsonSerializable()
class ValidatorResponse {
  @JsonKey(required: true)
  bool valid;

  ValidatorResponse({
    required this.valid,
  });

  factory ValidatorResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidatorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidatorResponseToJson(this);
}
