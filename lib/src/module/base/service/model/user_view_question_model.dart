import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'user_view_question_item_model.dart';

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

  factory UserViewQuestionModel.fromJson(Map<String, dynamic> json) {
    // Manually create the model since the generated code has issues
    return UserViewQuestionModel(
      order: json['order'] as int,
      section: json['section'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => UserViewQuestionItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    // Manually create the JSON since the generated code has issues
    return {
      'order': order,
      'section': section,
      'items': ConverterUtility.modelListToJsonList(items),
    };
  }
}
