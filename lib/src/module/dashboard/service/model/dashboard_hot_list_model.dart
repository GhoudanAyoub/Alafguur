import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../../base/service/model/user_model.dart';

part 'dashboard_hot_list_model.g.dart';

@JsonSerializable()
class DashboardHotListModel {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, toJson: ConverterUtility.modelToJson)
  final UserModel user;

  DashboardHotListModel({
    required this.id,
    required this.user,
  });

  factory DashboardHotListModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardHotListModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardHotListModelToJson(this);
}
