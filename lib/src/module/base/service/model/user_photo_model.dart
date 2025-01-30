import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'user_photo_model.g.dart';

@JsonSerializable()
class UserPhotoModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? id;

  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? userId;

  @JsonKey(required: true)
  final bool? approved;

  @JsonKey(required: true)
  final String? bigUrl;

  @JsonKey(required: true)
  final String? url;

  UserPhotoModel({
    this.id,
    this.userId,
    this.approved,
    this.bigUrl,
    this.url,
  });

  factory UserPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$UserPhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPhotoModelToJson(this);
}
