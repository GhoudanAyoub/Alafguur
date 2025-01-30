import 'package:json_annotation/json_annotation.dart';

part 'form_async_validator_model.g.dart';

@JsonSerializable()
class FormAsyncValidatorModel {
  @JsonKey(required: true)
  final String name;

  final String? message;

  @JsonKey(name: 'message_search_params')
  final List<String>? messageSearchParams;

  @JsonKey(name: 'message_replace_params')
  final List<String>? messageReplaceParams;

  final Map<String, dynamic>? params;

  FormAsyncValidatorModel({
    required this.name,
    this.message,
    this.messageSearchParams,
    this.messageReplaceParams,
    this.params,
  });

  factory FormAsyncValidatorModel.fromJson(Map<String, dynamic> json) {
    if (json['params'] is! Map) {
      json['params'] = <String, dynamic>{};
    }

    return _$FormAsyncValidatorModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FormAsyncValidatorModelToJson(this);
}
