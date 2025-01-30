import 'dart:async';

import 'package:browser_detector/browser_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../service/model/video_im_api_response_model.dart';
import '../../service/model/video_im_call_data_model.dart';
import '../../service/model/video_im_notification_model.dart';
import 'video_im_state.dart';

part 'video_im_call_state.g.dart';

typedef OnVideoImCallErrorCallback = void Function(String, String?);
typedef OnInterlocutorNoAnswerCallback = void Function();
typedef OnCallControlsHideTimerCallback = void Function();
typedef OnConnectionLossTimerCallback = void Function();
typedef OnCallMinuteCallback = void Function();
typedef OnCallRemotePeerConnectedCallback = void Function();

enum VideoImCallStatus {
  none,
  initializing,
  ongoing,
  noAnswer,
  connectionLost,
  finished,
}

class VideoImCallState = _VideoImCallState with _$VideoImCallState;

abstract class _VideoImCallState with Store {
  RootState rootState;
  VideoImState videoImState;
  BrowserDetector browserDetector;

  /// Interlocutor answer waiting time.
  static const _INTERLOCUTOR_ANSWER_TIMEOUT = const Duration(seconds: 120);

  /// Call controls hide timeout.
  static const _CALL_CONTROLS_HIDE_TIMEOUT = const Duration(seconds: 8);

  /// Connection loss timeout.
  static const _CONNECTION_LOSS_TIMEOUT = const Duration(seconds: 10);

  /// Call timer tick duration. Set to 1 second by default.
  static const _CALL_TIMER_DURATION = const Duration(seconds: 1);

  /// Local media stream.
  MediaStream? _localStream;

  /// Remote media stream.
  MediaStream? _remoteStream;

  /// Current video call data.
  late VideoImCallDataModel _callData;

  /// Video call peer connection.
  RTCPeerConnection? _peerConnection;

  /// Interlocutor answer timer. When it ticks, the interlocutor is considered
  /// non-responding and [onInterlocutorNoAnswerCallback] is triggered.
  Timer? _interlocutorAnswerTimer;

  /// Call controls hide timer. The call controls should hide on timeout.
  Timer? _callControlsHideTimer;

  /// Connection loss timer. When this timer triggers its timeout callback, the
  /// connection is considered lost without any chance of recovery.
  Timer? _connectionLossTimer;

  /// Video call timer. Used to measure the total length of the call, triggers
  /// [_onCallMinuteCallback] every 60 ticks.
  Timer? _callTimer;

  /// Video IM call error callback.
  OnVideoImCallErrorCallback? _onCallErrorCallback;

  /// No answer from the interlocutor callback.
  OnInterlocutorNoAnswerCallback? _onInterlocutorNoAnswerCallback;

  /// Call controls timer callback.
  OnCallControlsHideTimerCallback? _onCallControlsHideTimerCallback;

  /// Connection loss timer callback.
  OnConnectionLossTimerCallback? _onConnectionLossTimerCallback;

  /// Call minute callback. Triggered by the [_callTimer] every 60 ticks, which
  /// is more or less equal to 1 minute.
  OnCallMinuteCallback? _onCallMinuteCallback;

  /// Remote peer connected callback. Triggered when the connection with the
  /// remote peer has been established.
  OnCallRemotePeerConnectedCallback? _onCallRemotePeerConnectedCallback;

  /// Local video renderer.
  RTCVideoRenderer localRenderer = RTCVideoRenderer();

  /// Remote video renderer.
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  /// True if the [localRenderer] is initialized.
  @observable
  bool isLocalRendererReady = false;

  /// True if the [remoteRenderer] is initialized.
  @observable
  bool isRemoteRendererReady = false;

  /// True if the local video track is enabled.
  @observable
  bool isLocalVideoEnabled = true;

  /// True if the local audio track is enabled.
  @observable
  bool isLocalAudioEnabled = true;

  /// True if the call controls are displayed.
  @observable
  bool isCallControlsDisplayed = true;

  /// True if the call timer should be restarted after its next tick. Can be
  /// used to determine whether the call timer is started.
  ///
  /// The flag is set to true after the timer has been started and is reverted
  /// back to false after it has been cancelled.
  @observable
  bool isCallTimerStarted = false;

  /// Total call timer ticks.
  @observable
  int callTimerTicks = 0;

  /// Current call status.
  @observable
  VideoImCallStatus callStatus = VideoImCallStatus.none;

  /// Number of total [callTimerTicks] converted to HH:MM:SS format.
  @computed
  String get time {
    final hours = (callTimerTicks / 3600).floor();
    final minutes = ((callTimerTicks - hours * 3600) / 60).floor();
    final seconds = callTimerTicks - hours * 3600 - minutes * 60;

    final hoursStr = hours < 10 ? '0$hours' : '$hours';
    final minutesStr = minutes < 10 ? '0$minutes' : '$minutes';
    final secondsStr = seconds < 10 ? '0$seconds' : '$seconds';

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  /// Current call status translation key.
  @computed
  String get callStatusTextKey {
    switch (callStatus) {
      case VideoImCallStatus.initializing:
        return 'vim_calling';

      case VideoImCallStatus.ongoing:
        return 'vim_talking';

      case VideoImCallStatus.noAnswer:
        return 'vim_attempted_call_to';

      case VideoImCallStatus.finished:
        return 'vim_call_ended';

      default:
    }

    return '';
  }

  /// True if the call has either been finished normally or was dismissed as not
  /// answered.
  @computed
  bool get isCallFinished =>
      callStatus == VideoImCallStatus.finished ||
      callStatus == VideoImCallStatus.connectionLost ||
      callStatus == VideoImCallStatus.noAnswer;

  /// True if the connection has been established.
  @computed
  bool get isCallReady =>
      isLocalRendererReady &&
      isRemoteRendererReady &&
      callStatus == VideoImCallStatus.ongoing;

  /// Timed call permission from the global Video IM state.
  @computed
  UserPermissionModel? get timedCallPermission =>
      videoImState.timedCallPermission;

  /// True if the current call is tracked.
  bool get isCallTracked =>
      !rootState.isLoggedInAsAdmin &&
      videoImState.isCallTrackedForRole(_callData.role);

  /// True if the app is currently running in Safari browser.
  bool get isSafari => browserDetector.browser.isSafari;

  /// True if the `usercredits` plugin is enabled.
  bool get isUserCreditsPluginEnabled =>
      rootState.isPluginAvailable('usercredits');

  /// Set active call changed callback. Forwards the assignment to the global
  /// Video IM state.
  set onActiveCallChangedCallback(OnActiveCallChangedCallback value) {
    videoImState.onActiveCallChangedCallback = value;
  }

  /// Triggered when an error arises during the video call.
  set onCallErrorCallback(OnVideoImCallErrorCallback value) {
    _onCallErrorCallback = value;
  }

  /// Triggered when the interlocutor doesn't answer in reasonable time.
  set onInterlocutorNoAnswerCallback(OnInterlocutorNoAnswerCallback value) {
    _onInterlocutorNoAnswerCallback = value;
  }

  /// Triggered when the call controls are supposed to be hidden. The listener
  /// should somehow hide the controls when this callback is triggered.
  set onCallControlsHideTimerCallback(OnCallControlsHideTimerCallback value) {
    _onCallControlsHideTimerCallback = value;
  }

  /// Triggered when the connection is considered lost without any chance of
  /// recovery.
  set onConnectionLossTimerCallback(OnConnectionLossTimerCallback value) {
    _onConnectionLossTimerCallback = value;
  }

  /// Triggered every time the call timer passes 60 ticks, which is more or less
  /// equal to 1 minute.
  set onCallMinuteCallback(OnCallMinuteCallback value) {
    _onCallMinuteCallback = value;
  }

  /// Triggered when the connection with the remote peer has been established.
  set onCallRemotePeerConnectedCallback(
    OnCallRemotePeerConnectedCallback value,
  ) {
    _onCallRemotePeerConnectedCallback = value;
  }

  _VideoImCallState({
    required this.rootState,
    required this.videoImState,
    required this.browserDetector,
  });

  /// Initialize state.
  @action
  void init({
    required VideoImCallDataModel callData,
  }) {
    _callData = callData;

    videoImState.onActiveCallAnswerNotificationCallback = _onAnswerReceived;

    videoImState.onActiveCallCandidateNotificationCallback =
        _onCandidateNotificationReceived;

    videoImState.onActiveCallErrorNotificationCallback =
        _onErrorNotificationReceived;

    rootState.log(
      '[video_im] video im call widget initialized; interlocutor id: ${_callData.interlocutorId}',
    );
  }

  /// Initialize local video renderer.
  @action
  Future<bool> initializeLocalRenderer() async {
    try {
      await localRenderer.initialize();
    } catch (e) {
      _onCallErrorCallback?.call(e.toString(), null);
      return false;
    }

    isLocalRendererReady = true;

    return true;
  }

  /// Enable local audio stream.
  @action
  void enableLocalAudio() {
    final audioTracks = _localStream!.getAudioTracks();

    if (audioTracks.isNotEmpty) {
      audioTracks.first.enabled = true;
      isLocalAudioEnabled = true;
    }
  }

  /// Disable local audio stream.
  @action
  void disableLocalAudio() {
    final audioTracks = _localStream!.getAudioTracks();

    if (audioTracks.isNotEmpty) {
      audioTracks.first.enabled = false;
      isLocalAudioEnabled = false;
    }
  }

  /// Enable local video stream.
  @action
  void enableLocalVideo() {
    final videoTracks = _localStream!.getVideoTracks();

    if (videoTracks.isNotEmpty) {
      videoTracks.first.enabled = true;
      isLocalVideoEnabled = true;
    }
  }

  /// Disable local video stream.
  @action
  void disableLocalVideo() {
    final videoTracks = _localStream!.getVideoTracks();

    if (videoTracks.isNotEmpty) {
      videoTracks.first.enabled = false;
      isLocalVideoEnabled = false;
    }
  }

  /// Show call controls.
  @action
  void displayCallControls() {
    _cancelCallControlsHideTimer();

    isCallControlsDisplayed = true;

    _startCallControlsHideTimer();
  }

  /// Hide call controls.
  @action
  void hideCallControls() {
    _cancelCallControlsHideTimer();

    isCallControlsDisplayed = false;
  }

  /// Initialize remote video renderer.
  @action
  Future<bool> _initializeRemoteRenderer() async {
    try {
      await remoteRenderer.initialize();
      isRemoteRendererReady = true;
    } catch (e) {
      _onCallErrorCallback?.call(e.toString(), null);
      return false;
    }

    return true;
  }

  /// End active video call.
  @action
  Future<VideoImApiResponseModel?> endActiveCall({
    VideoImCallStatus withCallStatus = VideoImCallStatus.finished,
  }) {
    dispose();

    callStatus = withCallStatus;

    return videoImState.endActiveCall();
  }

  /// WebRTC ICE connection state change event handler.
  @action
  void _onRtcIceConnectionState(RTCIceConnectionState _) {
    // Start connection loss timer if the call has entered disconnected or
    // failed state.
    if (_peerConnection!.iceConnectionState ==
            RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
        _peerConnection!.iceConnectionState ==
            RTCIceConnectionState.RTCIceConnectionStateFailed) {
      _startConnectionLossTimer();
      return;
    }

    // Stop connection loss timer if the connection has entered any other state.
    _stopConnectionLossTimer();

    if (_peerConnection!.iceConnectionState !=
        RTCIceConnectionState.RTCIceConnectionStateConnected) {
      return;
    }

    rootState.log('[video_im] ICE connection state: connected');

    _cancelInterlocutorAnswerTimer();

    _onCallRemotePeerConnectedCallback?.call();
    callStatus = VideoImCallStatus.ongoing;

    _startCallTimer();
    _startCallControlsHideTimer();
  }

  /// Dispose of the allocated resources.
  void dispose() {
    _cancelCallTimer();

    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.dispose();

    if (isLocalRendererReady) {
      isLocalRendererReady = false;
      localRenderer.dispose();
    }

    if (isRemoteRendererReady) {
      isRemoteRendererReady = false;
      remoteRenderer.dispose();
    }

    _cancelInterlocutorAnswerTimer();
    _cancelCallControlsHideTimer();
  }

  /// Dismiss the current call as not answered.
  void dismissAsNotAnswered() {
    endActiveCall(withCallStatus: VideoImCallStatus.noAnswer);
  }

  /// Dismiss the current call as lost.
  void dismissAsLost() {
    endActiveCall(withCallStatus: VideoImCallStatus.connectionLost);
  }

  /// Attempts to get an audio/video stream from the user device. Stores it
  /// internally and resolves into true on success, into false otherwise.
  ///
  /// This method will attempt to get both audio and user-facing video stream
  /// first. If this fails, it will try to get an audio-only stream. If even
  /// this fails, it will resolve into false.
  Future<bool> initializeLocalMediaStream() async {
    final audioVideoConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    final audioConstraints = {
      'audio': true,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        audioVideoConstraints,
      );

      if (!isLocalAudioEnabled) {
        disableLocalAudio();
      }
    } catch (e) {
      try {
        _localStream = await navigator.mediaDevices.getUserMedia(
          audioConstraints,
        );

        if (!isLocalAudioEnabled) {
          disableLocalAudio();
        }
      } catch (e) {
        _onCallErrorCallback?.call(
          e.toString(),
          'vim_share_media_devices_error',
        );

        return false;
      }
    }

    return true;
  }

  /// Initialize peer connection.
  Future<bool> initializePeerConnection() async {
    try {
      await _initializePeerConnection();
    } catch (e) {
      _onCallErrorCallback?.call(e.toString(), null);
      return false;
    }

    return true;
  }

  /// Create local SDP description and send offer to the signalling service.
  void sendOffer() async {
    final description = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(description);

    // Preserve compatibility with the desktop plugin.
    if (description.sdp != null) {
      description.sdp = description.sdp!.replaceAll(
        RegExp(r'UDP/TLS/RTP/SAVPF'),
        'RTP/SAVPF',
      );
    }

    videoImState.sendOffer(
      _callData.interlocutorId,
      _callData.sessionId,
      description,
    );

    _startInterlocutorAnswerTimer();

    rootState.log('[video_im] offer sent');
  }

  /// Apply received remote description, create local answer description and
  /// send it to the interlocutor.
  void sendAnswer() async {
    await _peerConnection!.setRemoteDescription(_callData.offerDescription!);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    // Preserve compatibility with the desktop plugin.
    if (answer.sdp != null) {
      answer.sdp = answer.sdp!.replaceAll(
        RegExp(r'UDP/TLS/RTP/SAVPF'),
        'RTP/SAVPF',
      );
    }

    // Add stored candidates (if any)
    _callData.candidates!.forEach(
      (candidate) => _peerConnection!.addCandidate(candidate),
    );

    videoImState.sendAnswer(_callData, answer);
  }

  /// Attach local stream to the local renderer.
  void attachLocalStreamToLocalRenderer() {
    localRenderer.srcObject = _localStream;
  }

  /// Attach local stream to the peer connection.
  Future<bool> attachLocalStreamToPeerConnection() async {
    final addTrackFutures = <Future>[];

    _localStream!.getTracks().forEach(
      (element) {
        addTrackFutures.add(
          _peerConnection!.addTrack(element, _localStream!),
        );
      },
    );

    try {
      await Future.wait(addTrackFutures);
    } catch (e) {
      _onCallErrorCallback?.call(e.toString(), null);
      return false;
    }

    return true;
  }

  /// Track Video IM timed call action. Should be called every minute.
  Future<void> trackTimedCallAction() {
    return videoImState.trackTimedCallAction();
  }

  /// Send out of credits notification to the interlocutor.
  Future<VideoImApiResponseModel> sendCreditsOutNotification() {
    return videoImState.sendCreditsOutNotification(_callData);
  }

  /// Send not permitted notification to the interlocutor.
  Future<VideoImApiResponseModel> sendNotPermittedNotification() {
    return videoImState.sendNotPermittedNotification(_callData);
  }

  /// Create peer connection.
  Future<void> _initializePeerConnection() async {
    final iceServers = rootState.getSiteSetting('videoim_server_list', []);

    // fix native SDKs throwing an exception if there is a null in credentials
    final iceServersProcessed = iceServers.map(
      (serverData) {
        return {
          'urls': serverData['urls'],
          'username':
              serverData['username'] == null ? '' : serverData['username'],
          'credential':
              serverData['credential'] == null ? '' : serverData['credential'],
        };
      },
    ).toList();

    _peerConnection = await createPeerConnection(
      {
        'iceServers': iceServersProcessed,
        'sdpSemantics': 'unified-plan',
      },
      {
        'optional': [
          {
            'DtlsSrtpKeyAgreement': true,
          }
        ],
      },
    );

    _peerConnection!.onIceConnectionState = _onRtcIceConnectionState;
    _peerConnection!.onIceCandidate = _onRtcIceCandidate;
    _peerConnection!.onTrack = _onRtcTrack;
  }

  /// WebRTC ICE [candidate] generated event handler.
  void _onRtcIceCandidate(RTCIceCandidate candidate) {
    rootState.log('[video_im] ICE candidate generated');

    videoImState.sendIceCandidate(_callData.interlocutorId, candidate);
  }

  /// WebRTC remote track received event handler. The [event] parameter contains
  /// the event data.
  void _onRtcTrack(RTCTrackEvent event) async {
    rootState.log('[video_im] remote track received');

    _remoteStream = event.streams.first;

    if (!isRemoteRendererReady) {
      final isRemoteRendererInitialized = await _initializeRemoteRenderer();

      if (!isRemoteRendererInitialized) {
        return;
      }

      rootState.log('[video_im] remote renderer initialized');

      remoteRenderer.srcObject = _remoteStream;

      if (!kIsWeb) {
        _playRemoteAudioTrackOnSpeakerphone();
      }

      return;
    }

    remoteRenderer.srcObject = _remoteStream;

    if (!kIsWeb) {
      _playRemoteAudioTrackOnSpeakerphone();
    }
  }

  // Route remote audio track through the loudspeaker instead of the earpiece.
  void _playRemoteAudioTrackOnSpeakerphone() {
    final srcObject = remoteRenderer.srcObject!;
    final tracks = srcObject.getAudioTracks();

    if (tracks.isNotEmpty) {
      tracks.first.enableSpeakerphone(true);
    }
  }

  /// Handle active interlocutor answer notification received event.
  void _onAnswerReceived(VideoImNotificationModel answer) {
    rootState.log('[video_im] active interlocutor answer received');

    _peerConnection!.setRemoteDescription(
      RTCSessionDescription(
        answer.notificationBody['sdp'],
        answer.notificationBody['type'],
      ),
    );
  }

  /// Handle active interlocutor candidate notification received event.
  void _onCandidateNotificationReceived(RTCIceCandidate candidate) {
    rootState.log('[video_im] remote ICE candidate received');

    _peerConnection!.addCandidate(candidate);
  }

  /// Handle error notification received event.
  void _onErrorNotificationReceived(
    String notificationType,
    String errorTranslationKey,
  ) {
    // Stop connection loss timer after error notification was received.
    _stopConnectionLossTimer();

    // Inform the widget that an error notification has been received.
    _onCallErrorCallback?.call(notificationType, errorTranslationKey);
  }

  /// Start interlocutor answer timer.
  ///
  /// This timer will trigger the [onInterlocutorNoAnswerCallback] if no answer
  /// is received from the interlocutor in reasonable time.
  void _startInterlocutorAnswerTimer() {
    _interlocutorAnswerTimer = Timer(
      _INTERLOCUTOR_ANSWER_TIMEOUT,
      () => _onInterlocutorNoAnswerCallback?.call(),
    );
  }

  /// Cancel interlocutor answer timer.
  void _cancelInterlocutorAnswerTimer() {
    _interlocutorAnswerTimer?.cancel();
  }

  /// Start call controls display timer.
  ///
  /// This timer will trigger the [onCallControlsHideTimerCallback] on timeout.
  void _startCallControlsHideTimer() {
    _callControlsHideTimer = Timer(
      _CALL_CONTROLS_HIDE_TIMEOUT,
      () => _onCallControlsHideTimerCallback?.call(),
    );
  }

  /// Cancel call controls display timer.
  void _cancelCallControlsHideTimer() {
    _callControlsHideTimer?.cancel();
  }

  /// Start connection loss timer.
  ///
  /// This timer will trigger the [onConnectionLossTimerCallback] on timeout.
  void _startConnectionLossTimer() {
    if (_connectionLossTimer != null && _connectionLossTimer!.isActive) {
      return;
    }

    _connectionLossTimer = Timer(
      _CONNECTION_LOSS_TIMEOUT,
      () => _onConnectionLossTimerCallback?.call(),
    );
  }

  /// Stop connection loss timer.
  void _stopConnectionLossTimer() {
    _connectionLossTimer?.cancel();
  }

  /// Start the call timer.
  ///
  /// This timer will trigger the [onCallMinuteCallback] every 60 ticks, which
  /// is more or less equal to 1 minute.
  @action
  void _startCallTimer() {
    // Prevent call timer from starting multiple times on reconnections.
    if (_callTimer != null && _callTimer!.isActive) {
      return;
    }

    _callTimer = Timer.periodic(_CALL_TIMER_DURATION, _onCallTimerTick);
    isCallTimerStarted = true;
  }

  /// Cancel the call timer.
  @action
  void _cancelCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;

    isCallTimerStarted = false;
  }

  /// Call timer tick handler.
  @action
  void _onCallTimerTick(Timer _) {
    callTimerTicks++;

    if (callTimerTicks % 60 == 0) {
      _onCallMinuteCallback?.call();
    }
  }
}
