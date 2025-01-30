import 'package:json_annotation/json_annotation.dart';

part 'user_permission_model.g.dart';

@JsonSerializable()
class UserPermissionModel {
  @JsonKey(required: true)
  final String permission;

  @JsonKey(required: true)
  final bool isAllowedAfterTracking;

  @JsonKey(required: true)
  final bool isAllowed;

  @JsonKey(required: true)
  final bool isPromoted;

  @JsonKey(required: true)
  final bool authorizedByCredits;

  @JsonKey(required: true)
  final int creditsCost;

  UserPermissionModel({
    required this.permission,
    required this.isAllowedAfterTracking,
    required this.isAllowed,
    required this.isPromoted,
    required this.authorizedByCredits,
    required this.creditsCost,
  });

  factory UserPermissionModel.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPermissionModelToJson(this);
}
