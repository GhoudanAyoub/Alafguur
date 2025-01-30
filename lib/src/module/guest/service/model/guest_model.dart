import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../../base/service/model/user_model.dart';

part 'guest_model.g.dart';

@JsonSerializable()
class GuestModel {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  bool? viewed;

  @JsonKey(required: true)
  final int? visitTimestamp;

  @JsonKey(required: true)
  String? visitDate;

  @JsonKey(required: true, toJson: ConverterUtility.modelToJson)
  UserModel? user;

  GuestModel({
    required this.id,
    required this.viewed,
    required this.visitTimestamp,
    required this.user,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) =>
      _$GuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestModelToJson(this);
}
