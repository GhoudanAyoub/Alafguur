import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/debug_logger_widget_mixin.dart';
import '../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../service/model/video_im_call_data_model.dart';
import '../../service/model/video_im_call_widget_result_model.dart';
import '../../service/model/video_im_notification_model.dart';
import '../state/video_im_call_state.dart';
import '../style/video_im_call_widget_style.dart';
import '../style/video_im_widget_style.dart';

class VideoImCallWidget extends StatefulWidget
    with FlushbarWidgetMixin, ModalWidgetMixin, DebugLoggerWidgetMixin {
  final VideoImCallDataModel callData;

  VideoImCallWidget({
    required this.callData,
  });

  @override
  _VideoImCallWidgetState createState() => _VideoImCallWidgetState();
}

class _VideoImCallWidgetState extends State<VideoImCallWidget>
    with TickerProviderStateMixin {
  late final VideoImCallState _state;
  late final AnimationController _ripplesController;

  /// Call controls fade animation duration.
  static const _CALL_CONTROLS_FADE_DURATION = const Duration(milliseconds: 150);

  /// True if the call minute cost info should be displayed on the call view.
  bool get _displayMinuteCostInfo =>
      _state.timedCallPermission!.creditsCost != 0 && _state.isCallTracked;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<VideoImCallState>();

    _state.onCallErrorCallback = _dismissWithError;
    _state.onActiveCallChangedCallback = _endCall;
    _state.onInterlocutorNoAnswerCallback = _onInterlocutorNoAnswer;
    _state.onCallControlsHideTimerCallback = _onCallControlsHideTimer;
    _state.onConnectionLossTimerCallback = _onConnectionLost;
    _state.onCallMinuteCallback = _onCallMinutePassed;
    _state.onCallRemotePeerConnectedCallback = _onRemotePeerConnected;

    _ripplesController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    /// Initialize the call state.
    _state.init(callData: widget.callData);

    /// Initialize the call itself.
    _initCall();
  }

  @override
  void dispose() {
    _ripplesController.dispose();
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      body: Observer(
        builder: (_) =>
            !_state.isCallReady ? _buildDialScreenView() : _buildCallView(),
      ),
    );
  }

  /// Build dial the dial screen view. Displayed while the call is connecting
  /// and after the call has ended.
  Widget _buildDialScreenView() {
    // There is no initial dial screen for the interlocutor, however there is a
    // final dial screen that should be displayed after the call has ended.
    //
    // This statement ensures that the normal call view is displayed to the
    // interlocutor if the call has just begun, but when the call has ended,
    // the final dial screen is rendered instead.
    if (widget.callData.role == VideoImCallRole.interlocutor &&
        !_state.isCallFinished) {
      return _buildCallView();
    }

    return Observer(
      builder: (_) {
        return videoImWidgetBlurBackroundWrapperContainer(
          Stack(
            fit: StackFit.expand,
            children: [
              // Dial screen controls.
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Calling to <display-name>.
                        Column(
                          children: [
                            // Call status text: calling to, no answer, etc.
                            videoImWidgetActionTextContainer(
                              LocalizationService.of(context).t(
                                _state.callStatusTextKey,
                              ),
                              _state.isCallReady,
                            ),

                            // <display-name>
                            videoImWidgetNameTextContainer(
                              widget.callData.interlocutorDisplayName,
                            ),
                          ],
                        ),
                        videoImWidgetContWrapperContainer(
                          [
                            // Interlocutor avatar.
                            if (_state.isCallFinished)
                              videoImWidgetAvatarContainer(
                                widget.callData.interlocutorAvatarUrl,
                              )
                            else
                              videoImWidgetRipplesAnimationAvatarContainer(
                                widget.callData.interlocutorAvatarUrl,
                                _ripplesController,
                              ),

                            /// No answer text.
                            if (_state.callStatus == VideoImCallStatus.noAnswer)
                              videoImCallWidgetNoAnswerTextContainer(
                                LocalizationService.of(context).t(
                                  'vim_no_answer',
                                ),
                              ),

                            // Connection lost text.
                            if (_state.callStatus ==
                                VideoImCallStatus.connectionLost)
                              videoImCallWidgetNoAnswerTextContainer(
                                LocalizationService.of(context).t(
                                  'vim_connection_lost',
                                ),
                              ),

                            /// Total call time.
                            if (_state.callStatus ==
                                    VideoImCallStatus.finished ||
                                _state.callStatus ==
                                    VideoImCallStatus.connectionLost)
                              videoImCallWidgetTimeTextContainer(
                                _state.time,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Control buttons.
                  videoImWidgetButtonsWrapperContainer(
                    [
                      // Mute audio or call the same user again if the call has
                      // ended.
                      if (_state.callStatus == VideoImCallStatus.finished)
                        videoImWidgetCallIconContainer(
                          context,
                          LocalizationService.of(context).t(
                            'vim_tooltip_call_again',
                          ),
                          () => _callAgain(),
                        )
                      else
                        videoImWidgetMuteCallIconContainer(
                          context,
                          _state.isLocalAudioEnabled
                              ? LocalizationService.of(context).t(
                                  'vim_tooltip_mute',
                                )
                              : LocalizationService.of(context).t(
                                  'vim_tooltip_unmute',
                                ),
                          () => _changeAudioEnabledStatus(),
                          _state.isLocalAudioEnabled,
                        ),

                      /// End video call.
                      if (_state.callStatus == VideoImCallStatus.finished)
                        videoImWidgetCloseCallIconContainer(
                          context,
                          LocalizationService.of(context).t(
                            'vim_tooltip_end_call',
                          ),
                          () => _endCall(),
                        )
                      else
                        videoImWidgetEndCallIconContainer(
                          context,
                          LocalizationService.of(context).t(
                            'vim_tooltip_end_call',
                          ),
                          () => _endCall(),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          widget.callData.interlocutorAvatarUrl,
        );
      },
    );
  }

  /// Build connected video call view. Called after the connection has been
  /// established.
  Widget _buildCallView() {
    return Observer(
      builder: (BuildContext context) {
        return videoImCallWidgetWrapperContainer(
          Stack(
            children: <Widget>[
              // Remote video.
              _remoteVideoWidget(),

              // Transparent background to catch gestures.
              GestureDetector(
                child: SizedBox.expand(
                  child: Container(
                    color: transparentColor(),
                  ),
                ),
                onTap: _onCallAreaTap,
              ),

              // Call information: talking to <name>. This widget fades ouf if
              // the call controls are invisible.
              videoImCallWidgetFadingTextWrapperContainer(
                Column(
                  children: [
                    // "Talking to"
                    videoImWidgetActionTextContainer(
                      LocalizationService.of(context).t(
                        'vim_talking',
                      ),
                      _state.isCallReady,
                    ),

                    // <display-name>
                    videoImWidgetNameTextContainer(
                      widget.callData.interlocutorDisplayName,
                    ),
                  ],
                ),
                context,
                _state.isCallControlsDisplayed,
                _CALL_CONTROLS_FADE_DURATION,
              ),

              // Local video.
              if (!_state.isSafari)
                videoImCallWidgetLocalVideoWrapperContainer(
                  _localVideoWidget(),
                  context,
                  _state.isCallControlsDisplayed,
                  _CALL_CONTROLS_FADE_DURATION,
                ),

              // Call control pane.
              videoImCallWidgetControlPaneWrapperContainer(
                [
                  // Call control buttons row.
                  videoImWidgetButtonsWrapperContainer(
                    [
                      // Enable/disable local sound button.
                      videoImWidgetMuteCallIconContainer(
                        context,
                        _state.isLocalAudioEnabled
                            ? LocalizationService.of(context).t(
                                'vim_tooltip_mute',
                              )
                            : LocalizationService.of(context).t(
                                'vim_tooltip_unmute',
                              ),
                        () => _changeAudioEnabledStatus(),
                        _state.isLocalAudioEnabled,
                      ),

                      // End call button.
                      videoImWidgetEndCallIconContainer(
                        context,
                        LocalizationService.of(context).t(
                          'vim_tooltip_end_call',
                        ),
                        () => _disconnect(),
                      ),

                      // Enable/disable local video button.
                      videoImWidgetVideoIconContainer(
                        context,
                        _state.isLocalVideoEnabled
                            ? LocalizationService.of(context).t(
                                'vim_tooltip_disable_video',
                              )
                            : LocalizationService.of(context).t(
                                'vim_tooltip_enable_video',
                              ),
                        () => _changeVideoEnabledStatus(),
                        _state.isLocalVideoEnabled,
                      ),
                    ],
                  ),

                  // Call timer.
                  if (_state.isCallTimerStarted)
                    videoImCallWidgetCallTimerContainer(
                      _state.time,
                      paidCallInfo: _displayMinuteCostInfo
                          ? LocalizationService.of(context).t(
                              'vim_mobile_timed_call_info',
                              searchParams: [
                                'amount',
                              ],
                              replaceParams: [
                                _state.timedCallPermission!.creditsCost
                                    .toString(),
                              ],
                            )
                          : null,
                    ),
                ],
                context,
                _state.isCallControlsDisplayed,
                _CALL_CONTROLS_FADE_DURATION,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Render remote video widget.
  Widget _remoteVideoWidget() {
    if (!_state.isRemoteRendererReady) {
      return videoImCallWidgetEmptyRemoteVideoContainer();
    }

    return RTCVideoView(
      _state.remoteRenderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }

  /// Render local video widget.
  Widget _localVideoWidget() {
    return videoImCallWidgetLocalVideoContainer(
      context,
      RTCVideoView(
        _state.localRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      ),
    );
  }

  /// Perform the video call initialization sequence.
  void _initCall() async {
    _state.callStatus = VideoImCallStatus.initializing;

    final isLocalMediaStreamInitialized =
        await _state.initializeLocalMediaStream();

    if (!isLocalMediaStreamInitialized) {
      _dismissWithError('cannot initialize local media stream', null);
      return;
    }

    widget.debugLog('[video_im] local stream initialized');

    final isLocalRendererInitialized = await _state.initializeLocalRenderer();

    if (!isLocalRendererInitialized) {
      _dismissWithError('cannot initialize local renderer', null);
      return;
    }

    widget.debugLog('[video_im] local renderer initialized');

    final isPeerConnectionInitialized = await _state.initializePeerConnection();

    if (!isPeerConnectionInitialized) {
      _dismissWithError('cannot initialize peer connection', null);
      return;
    }

    widget.debugLog('[video_im] peer connection initialized');

    _state.attachLocalStreamToLocalRenderer();

    final isLocalStreamAttached =
        await _state.attachLocalStreamToPeerConnection();

    if (!isLocalStreamAttached) {
      _dismissWithError('cannot attach local stream to peer connection', null);
      return;
    }

    widget.debugLog('[video_im] attached local stream to the peer connection');

    if (widget.callData.role == VideoImCallRole.initiator) {
      _state.sendOffer();
    } else {
      _state.sendAnswer();
    }
  }

  /// Dismiss the current call without closing the modal.
  void _disconnect() {
    _state.endActiveCall();
  }

  /// End the current call.
  void _endCall() {
    _disconnect();

    // The empty map is required.
    Navigator.pop(context, VideoImCallWidgetResultModel(callAgain: false));
  }

  /// End the current call and call the same user again.
  void _callAgain() {
    _state.endActiveCall();

    Navigator.pop(
      context,
      VideoImCallWidgetResultModel(
        callAgain: true,
        callData: widget.callData,
      ),
    );
  }

  /// Handle interlocutor not responding answer in reasonable time.
  void _onInterlocutorNoAnswer() {
    _state.dismissAsNotAnswered();
  }

  /// Handle connection loss.
  void _onConnectionLost() {
    _state.dismissAsLost();
  }

  /// Handle call controls hide timer tick.
  void _onCallControlsHideTimer() {
    _state.hideCallControls();
  }

  /// Triggered every time a minute passes in call.
  void _onCallMinutePassed() {
    if (_state.isCallTracked) {
      if (_state.timedCallPermission != null &&
          _state.isUserCreditsPluginEnabled &&
          !_state.timedCallPermission!.isAllowed &&
          _state.timedCallPermission!.creditsCost != 0) {
        _state.sendCreditsOutNotification();
        _dismissWithError(null, 'vim_call_ended_you_ran_out_of_credits');

        return;
      }

      _state.trackTimedCallAction();
    }
  }

  /// Triggered when the remote peer connection has been established.
  void _onRemotePeerConnected() {
    _ripplesController.stop();
  }

  /// Handle video call area tap.
  void _onCallAreaTap() {
    _state.displayCallControls();
  }

  /// Change audio track enabled status.
  void _changeAudioEnabledStatus() {
    if (_state.isLocalAudioEnabled) {
      _state.disableLocalAudio();
    } else {
      _state.enableLocalAudio();
    }
  }

  /// Change video track enabled status.
  void _changeVideoEnabledStatus() {
    if (_state.isLocalVideoEnabled) {
      _state.disableLocalVideo();
    } else {
      _state.enableLocalVideo();
    }
  }

  /// Dismiss video call modal with error.
  void _dismissWithError(String? errorType, String? errorTranslationKey) {
    var showErrorMessage = true;

    if (errorType != null && errorType.isNotEmpty) {
      switch (errorType) {
        case VideoImNotificationType.blocked:
          showErrorMessage = false;
          _handleBlockedByInterlocutor();
          break;

        default:
          widget.debugLog('[video_im] widget fatal error: $errorType');
          break;
      }
    }

    _disconnect();

    if (showErrorMessage &&
        errorTranslationKey != null &&
        errorTranslationKey.isNotEmpty) {
      widget.showMessage(errorTranslationKey, context);
    }
  }

  /// Handle call blocked by the interlocutor.
  void _handleBlockedByInterlocutor() {
    widget.showAlert(
      context,
      LocalizationService.of(context).t(
        'vim_you_have_been_blocked_by',
        searchParams: ['name'],
        replaceParams: [widget.callData.interlocutorDisplayName],
      ),
      translate: false,
    );
  }
}
