import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'user_bookmark_model.g.dart';

@JsonSerializable()
class UserBookmarkModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? id;

  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? user;

  UserBookmarkModel({
    this.id,
    this.user,
  });

  factory UserBookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$UserBookmarkModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserBookmarkModelToJson(this);
}
