import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'user_avatar_model.g.dart';

@JsonSerializable()
class UserAvatarModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? id;

  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? userId;

  @JsonKey(required: true)
  final bool? active;

  @JsonKey(required: true)
  final String? bigUrl;

  @JsonKey(required: true)
  final String? pendingBigUrl;

  @JsonKey(required: true)
  final String? pendingUrl;

  @JsonKey(required: true)
  final String? url;

  UserAvatarModel({
    this.id,
    this.userId,
    this.active,
    this.bigUrl,
    this.pendingBigUrl,
    this.pendingUrl,
    this.url,
  });

  factory UserAvatarModel.fromJson(Map<String, dynamic> json) =>
      _$UserAvatarModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAvatarModelToJson(this);
}
