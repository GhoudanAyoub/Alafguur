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

    // Manually create the model since the generated code has issues
    return UserModel(
      id: ConverterUtility.dynamicToInt(json['id']),
      userName: json['userName'] as String?,
      isOnline: json['isOnline'] as bool?,
      age: ConverterUtility.dynamicToInt(json['age']),
      aboutMe: json['aboutMe'] as String?,
      distance: json['distance'] != null
          ? UserDistanceModel.fromJson(json['distance'] as Map<String, dynamic>)
          : null,
      sex: ConverterUtility.dynamicToInt(json['sex']),
      password: json['password'] as String?,
      email: json['email'] as String?,
      lookingFor: ConverterUtility.dynamicListToInt(json['lookingFor']),
      avatarKey: json['avatarKey'] as String?,
      avatar: json['avatar'] != null
          ? UserAvatarModel.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      bookmark: json['bookmark'] != null
          ? UserBookmarkModel.fromJson(json['bookmark'] as Map<String, dynamic>)
          : null,
      matchAction: json['matchAction'] != null
          ? UserMatchActionModel.fromJson(
              json['matchAction'] as Map<String, dynamic>)
          : null,
      videoImCallPermission: json['videoImCallPermission'] != null
          ? VideoImCallPermissionModel.fromJson(
              json['videoImCallPermission'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
      compatibility: json['compatibility'] as int?,
      type: json['type'] as String?,
      isAdmin: json['isAdmin'] as bool?,
      isBlocked: json['isBlocked'] as bool?,
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => UserPermissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      viewQuestions: (json['viewQuestions'] as List<dynamic>?)
          ?.map((e) => UserViewQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => UserPhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    // Manually create the JSON since the generated code has issues
    final Map<String, dynamic> json = {};
    
    if (id != null) json['id'] = id;
    if (userName != null) json['userName'] = userName;
    if (isOnline != null) json['isOnline'] = isOnline;
    if (age != null) json['age'] = age;
    if (aboutMe != null) json['aboutMe'] = aboutMe;
    if (distance != null) json['distance'] = ConverterUtility.modelToJson(distance);
    if (sex != null) json['sex'] = sex;
    if (password != null) json['password'] = password;
    if (email != null) json['email'] = email;
    if (lookingFor != null) json['lookingFor'] = lookingFor;
    if (avatarKey != null) json['avatarKey'] = avatarKey;
    if (avatar != null) json['avatar'] = ConverterUtility.modelToJson(avatar);
    json['bookmark'] = ConverterUtility.modelToJson(bookmark);
    json['matchAction'] = ConverterUtility.modelToJson(matchAction);
    if (videoImCallPermission != null) {
      json['videoImCallPermission'] = ConverterUtility.modelToJson(videoImCallPermission);
    }
    if (token != null) json['token'] = token;
    if (compatibility != null) json['compatibility'] = compatibility;
    if (type != null) json['type'] = type;
    if (isAdmin != null) json['isAdmin'] = isAdmin;
    if (isBlocked != null) json['isBlocked'] = isBlocked;
    if (permissions != null) {
      json['permissions'] = ConverterUtility.modelListToJsonList(permissions);
    }
    if (viewQuestions != null) {
      json['viewQuestions'] = ConverterUtility.modelListToJsonList(viewQuestions);
    }
    if (photos != null) {
      json['photos'] = ConverterUtility.modelListToJsonList(photos);
    }
    
    return json;
  }
}
