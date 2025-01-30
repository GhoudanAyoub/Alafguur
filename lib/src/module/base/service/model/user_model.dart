import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import 'user_avatar_model.dart';
import 'user_bookmark_model.dart';
import 'user_distance_model.dart';
import 'user_match_action_model.dart';
import 'user_permission_model.dart';
import 'user_photo_model.dart';
import 'user_view_question_model.dart';
import 'video_im_call_permission_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(includeIfNull: false, fromJson: ConverterUtility.dynamicToInt)
  final int? id;

  @JsonKey(includeIfNull: false)
  final String? userName;

  @JsonKey(includeIfNull: false)
  final bool? isOnline;

  @JsonKey(includeIfNull: false)
  final int? age;

  @JsonKey(includeIfNull: false)
  final String? aboutMe;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelToJson)
  final UserDistanceModel? distance;

  @JsonKey(includeIfNull: false, fromJson: ConverterUtility.dynamicToInt)
  final int? sex;

  @JsonKey(includeIfNull: false)
  final String? password;

  @JsonKey(includeIfNull: false)
  final String? email;

  @JsonKey(includeIfNull: false, fromJson: ConverterUtility.dynamicListToInt)
  final List<int>? lookingFor;

  @JsonKey(includeIfNull: false)
  final String? avatarKey;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelToJson)
  UserAvatarModel? avatar;

  @JsonKey(includeIfNull: true, toJson: ConverterUtility.modelToJson)
  UserBookmarkModel? bookmark;

  @JsonKey(includeIfNull: true, toJson: ConverterUtility.modelToJson)
  UserMatchActionModel? matchAction;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelToJson)
  VideoImCallPermissionModel? videoImCallPermission;

  @JsonKey(includeIfNull: false)
  final String? token;

  @JsonKey(includeIfNull: false)
  final int? compatibility;

  @JsonKey(includeIfNull: false)
  final String? type;

  @JsonKey(includeIfNull: false)
  final bool? isAdmin;

  @JsonKey(includeIfNull: false)
  bool? isBlocked;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelListToJsonList)
  List<UserPermissionModel>? permissions;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelListToJsonList)
  List<UserViewQuestionModel>? viewQuestions;

  @JsonKey(includeIfNull: false, toJson: ConverterUtility.modelListToJsonList)
  List<UserPhotoModel>? photos;

  UserModel({
    this.id,
    this.userName,
    this.isOnline,
    this.age,
    this.aboutMe,
    this.distance,
    this.sex,
    this.password,
    this.email,
    this.lookingFor,
    this.avatarKey,
    this.avatar,
    this.bookmark,
    this.matchAction,
    this.videoImCallPermission,
    this.token,
    this.compatibility,
    this.type,
    this.isAdmin,
    this.isBlocked,
    this.permissions,
    this.viewQuestions,
    this.photos,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // sometimes the api response provides a sex value as a list of a single value
    if (json['sex'] is List) {
      json['sex'] = json['sex'].first;
    }

    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
