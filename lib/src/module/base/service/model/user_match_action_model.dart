import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'user_match_action_model.g.dart';

enum MatchActionTypeEnum {
  like,
  dislike,
}

@JsonSerializable()
class UserMatchActionModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int id;

  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int userId;

  @JsonKey(required: true)
  final MatchActionTypeEnum type;

  @JsonKey(includeIfNull: false, fromJson: ConverterUtility.dynamicToInt)
  final int? createStamp;

  @JsonKey(includeIfNull: false)
  bool? isMutual;

  @JsonKey(includeIfNull: false)
  bool? isNew;

  @JsonKey(includeIfNull: false)
  bool? isRead;

  UserMatchActionModel({
    required this.id,
    required this.userId,
    required this.type,
    this.createStamp,
    this.isMutual,
    this.isNew,
    this.isRead,
  });

  factory UserMatchActionModel.fromJson(Map<String, dynamic> json) =>
      _$UserMatchActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserMatchActionModelToJson(this);
}
