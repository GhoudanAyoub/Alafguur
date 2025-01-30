import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'user_view_question_item_model.dart';

part 'user_view_question_model.g.dart';

@JsonSerializable()
class UserViewQuestionModel {
  @JsonKey(required: true)
  final int order;

  @JsonKey(required: true)
  final String section;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelListToJsonList)
  List<UserViewQuestionItemModel> items;

  UserViewQuestionModel({
    required this.order,
    required this.section,
    required this.items,
  });

  factory UserViewQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$UserViewQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserViewQuestionModelToJson(this);
}
