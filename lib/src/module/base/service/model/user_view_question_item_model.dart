import 'package:json_annotation/json_annotation.dart';

part 'user_view_question_item_model.g.dart';

@JsonSerializable()
class UserViewQuestionItemModel {
  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String label;

  @JsonKey(required: true)
  final String value;

  UserViewQuestionItemModel({
    required this.name,
    required this.label,
    required this.value,
  });

  factory UserViewQuestionItemModel.fromJson(Map<String, dynamic> json) =>
      _$UserViewQuestionItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserViewQuestionItemModelToJson(this);
}
