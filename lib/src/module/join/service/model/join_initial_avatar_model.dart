import 'package:json_annotation/json_annotation.dart';

part 'join_initial_avatar_model.g.dart';

@JsonSerializable()
class JoinInitialAvatarModel {
  @JsonKey(required: true)
  final String key;

  @JsonKey(required: true)
  final String url;

  JoinInitialAvatarModel({
    required this.key,
    required this.url,
  });

  factory JoinInitialAvatarModel.fromJson(Map<String, dynamic> json) =>
      _$JoinInitialAvatarModelFromJson(json);

  Map<String, dynamic> toJson() => _$JoinInitialAvatarModelToJson(this);
}
