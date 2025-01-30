import 'package:json_annotation/json_annotation.dart';

part 'generic_response_model.g.dart';

@JsonSerializable()
class GenericResponseModel {
  @JsonKey(required: true)
  final bool success;

  @JsonKey(required: false)
  final String? message;

  GenericResponseModel({
    required this.success,
    this.message,
  });

  factory GenericResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GenericResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenericResponseModelToJson(this);
}
