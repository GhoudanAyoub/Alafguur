import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../../base/service/model/user_model.dart';

part 'dashboard_matched_user_model.g.dart';

@JsonSerializable()
class DashboardMatchedUserModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int id;

  @JsonKey(required: true)
  bool isViewed;

  @JsonKey(required: true)
  bool isNew;

  @JsonKey(required: true)
  int createStamp;

  @JsonKey(required: true, toJson: ConverterUtility.modelToJson)
  UserModel user;

  DashboardMatchedUserModel({
    required this.id,
    required this.isViewed,
    required this.isNew,
    required this.user,
    required this.createStamp,
  });

  factory DashboardMatchedUserModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardMatchedUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardMatchedUserModelToJson(this);
}
