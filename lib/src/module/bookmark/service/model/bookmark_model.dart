import 'package:json_annotation/json_annotation.dart';

import '../../../../app/utility/converter_utility.dart';
import '../../../base/service/model/user_model.dart';

part 'bookmark_model.g.dart';

@JsonSerializable()
class BookmarkModel {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, toJson: ConverterUtility.modelToJson)
  UserModel user;

  BookmarkModel({
    required this.id,
    required this.user,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarkModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkModelToJson(this);
}
