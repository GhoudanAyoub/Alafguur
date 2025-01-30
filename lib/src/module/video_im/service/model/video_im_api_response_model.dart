import 'package:json_annotation/json_annotation.dart';

part 'video_im_api_response_model.g.dart';

@JsonSerializable()
class VideoImApiResponseModel {
  final bool result;
  final String? message;

  const VideoImApiResponseModel({
    required this.result,
    required this.message,
  });

  factory VideoImApiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VideoImApiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoImApiResponseModelToJson(this);
}
