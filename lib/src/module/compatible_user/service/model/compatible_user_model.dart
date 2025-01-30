import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../../base/service/model/user_model.dart';

part 'compatible_user_model.g.dart';

@JsonSerializable()
class CompatibleUserModel {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, toJson: ConverterUtility.modelToJson)
  UserModel user;

  CompatibleUserModel({
    required this.id,
    required this.user,
  });

  factory CompatibleUserModel.fromJson(Map<String, dynamic> json) =>
      _$CompatibleUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompatibleUserModelToJson(this);
}
