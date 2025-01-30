import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobx/mobx.dart';

import '../../service/model/video_im_call_data_model.dart';
import 'video_im_state.dart';

part 'video_im_accept_call_state.g.dart';

class VideoImAcceptCallState = _VideoImAcceptCallState
    with _$VideoImAcceptCallState;

abstract class _VideoImAcceptCallState with Store {
  VideoImState videoImState;

  /// Default ringtone volume.
  static const _RINGTONE_VOLUME = 0.8;

  /// Path to the ringtone music file.
  static const _RINGTONE_ASSET_PATH = 'assets/sound/video_im/ring.mp3';

  /// Ringtone audio player.
  late AudioPlayer _ringtonePlayer;

  /// True if the ringtone is currently playing.
  @observable
  bool isRingtoneEnabled = !kIsWeb;

  /// List of ICE candidates received with the call offer.
  List<RTCIceCandidate> get storedCandidates => videoImState.storedCandidates;

  _VideoImAcceptCallState({
    required this.videoImState,
  });

  /// Initialize state.
  void init() async {
    final ringtonePlayerInitialization = <Future>[];

    _ringtonePlayer = AudioPlayer();

    ringtonePlayerInitialization.add(_ringtonePlayer.setLoopMode(LoopMode.one));

    ringtonePlayerInitialization.add(
      _ringtonePlayer.setVolume(_RINGTONE_VOLUME),
    );

    ringtonePlayerInitialization.add(
      _ringtonePlayer.setAsset(_RINGTONE_ASSET_PATH),
    );

    await Future.wait(ringtonePlayerInitialization);

    if (isRingtoneEnabled) {
      _ringtonePlayer.play();
    }
  }

  /// Start playing the ringtone.
  @action
  Future<void> enableRingtone() async {
    isRingtoneEnabled = true;
    await _ringtonePlayer.play();
  }

  /// Fully disable ringtone and dispose of the decoders.
  @action
  Future<void> disableRingtone() async {
    isRingtoneEnabled = false;
    await _ringtonePlayer.stop();
  }

  /// Pause ringtone instead of fully stopping the playback for faster resume.
  @action
  Future<void> pauseRingtone() async {
    isRingtoneEnabled = false;
    await _ringtonePlayer.pause();
  }

  /// Globally set [callData] as the active call data.
  void setActiveCallData(VideoImCallDataModel callData) {
    videoImState.setActiveCallData(callData);
  }

  /// Block the caller in the provided [callData].
  void blockCaller(VideoImCallDataModel callData) {
    videoImState.blockCaller(callData);
  }

  /// Decline call represented by the provided [callData].
  void declineCall(VideoImCallDataModel callData) {
    videoImState.declineCall(callData);
  }
}
