import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';

part 'user_distance_model.g.dart';

@JsonSerializable()
class UserDistanceModel {
  @JsonKey(required: true, fromJson: ConverterUtility.dynamicToInt)
  final int? distance;

  @JsonKey(required: true)
  final String? unit;

  UserDistanceModel({
    this.distance,
    this.unit,
  });

  factory UserDistanceModel.fromJson(Map<String, dynamic> json) =>
      _$UserDistanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDistanceModelToJson(this);
}
