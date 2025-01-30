
import 'video_im_call_data_model.dart';

/// Call widget result, returned by the [VideoImCallWidget] after it has been
/// dismissed.
class VideoImCallWidgetResultModel {
  /// Indicates whether the user has pressed the "call again" button.
  final bool callAgain;

  /// Previous call data.
  final VideoImCallDataModel? callData;

  const VideoImCallWidgetResultModel({
    required this.callAgain,
    this.callData,
  });
}
