import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mobx/mobx.dart';

import '../../../../app/service/auth_service.dart';
import '../../../../app/service/random_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../../base/service/permissions_service.dart';
import '../../../base/service/user_service.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../service/model/video_im_api_response_model.dart';
import '../../service/model/video_im_call_data_model.dart';
import '../../service/model/video_im_notification_model.dart';
import '../../service/video_im_service.dart';

part 'video_im_state.g.dart';

/// Video IM notifications.
class _VideoImNotifications {
  static const Map notPermitted = {
    'type': VideoImNotificationType.notPermitted
  };

  static const Map creditsOut = {
    'type': VideoImNotificationType.creditsOut,
  };

  static const Map candidate = {
    'type': VideoImNotificationType.candidate,
  };

  static const Map declined = {
    'type': VideoImNotificationType.declined,
  };

  static const Map bye = {
    'type': VideoImNotificationType.bye,
  };

  /// Create a notification based on [base] with [data] attached.
  static Map withData(Map base, Map data) => {...base, ...data};
}

/// Video IM credits tracking modes.
class _VideoImCreditsTrackingMode {
  static const String initiator = 'initiator';
  static const String interlocutor = 'interlocutor';
  static const String both = 'both';
}

typedef OnActiveCallChangedCallback = void Function();

typedef OnActiveCallAnswerNotificationCallback = void Function(
  VideoImNotificationModel,
);

typedef OnActiveCallCandidateNotificationCallback = void Function(
  RTCIceCandidate candidate,
);

typedef OnActiveCallErrorNotificationCallback = void Function(String, String);

class VideoImState = _VideoImState with _$VideoImState;

abstract class _VideoImState with Store {
  final RootState rootState;
  final DashboardUserState dashboardUserState;
  final VideoImService videoImService;
  final AuthService authService;
  final RandomService randomService;
  final PermissionsService permissionsService;
  final UserService userService;

  late ReactionDisposer _permissionsDisposer;

  /// Action group name for action tracking.
  final String _videoImActionGroupName = 'videoim';

  /// Timed call action name for action tracking.
  final String _videoImTimedCallActionName = 'video_im_timed_call';

  /// Video call permission name.
  final String _callPermissionName = 'videoim_video_im_call';

  /// Video call receive permission name.
  final String _receivePermissionName = 'videoim_video_im_receive';

  /// Timed call permission name.
  final String _timedCallPermissionName = 'videoim_video_im_timed_call';

  /// Set of processed notification IDs to avoid processing same notifications
  /// again.
  final Set<int> _processedNotificationIds = Set<int>();

  /// Called when the active call is changed.
  OnActiveCallChangedCallback? onActiveCallChangedCallback;

  /// Called when the answer notification for the active call is received.
  OnActiveCallAnswerNotificationCallback?
      onActiveCallAnswerNotificationCallback;

  /// Called when a candidate notification for the active call is received.
  OnActiveCallCandidateNotificationCallback?
      onActiveCallCandidateNotificationCallback;

  /// Called when an error notification for the active call is received.
  OnActiveCallErrorNotificationCallback? onActiveCallErrorNotificationCallback;

  /// Stored offer candidates to add once the offer is accepted.
  List<RTCIceCandidate> storedCandidates = [];

  /// Determines whether the user can make a video call.
  @observable
  UserPermissionModel? callPermission;

  /// Determines whether the user can receive video calls.
  @observable
  UserPermissionModel? receivePermission;

  /// Determines whether the user can continue the call (has enough credits for
  /// the next minute).
  @observable
  UserPermissionModel? timedCallPermission;

  /// Call offer stack.
  @observable
  List<VideoImCallDataModel> offers = [];

  /// Current active call data object.
  @observable
  VideoImCallDataModel? activeCall;

  /// True if a video call offer is being sent.
  @observable
  bool? isSendOfferPending;

  /// VideoImState constructor.
  _VideoImState({
    required this.rootState,
    required this.dashboardUserState,
    required this.videoImService,
    required this.authService,
    required this.randomService,
    required this.permissionsService,
    required this.userService,
  });

  /// Initialize state.
  @action
  void init() {
    // _initVideoImUpdatesWatcher();
    _initPermissionsWatcher();

    // Get initial permission values.
    _updateVideoImPermissions();
  }

  /// Generates a [VideoImCallDataModel] representing a call to the given
  /// [user] and sets it as the active call data.
  void call(UserModel user) {
    if (user.id != authService.authUser!.id) {
      setActiveCallData(
        VideoImCallDataModel(
          interlocutorId: user.id!,
          interlocutorAvatarUrl: _getAvatarUrl(user)!,
          interlocutorDisplayName: user.userName!,
          role: VideoImCallRole.initiator,
          sessionId: generateSessionId(),
        ),
      );
    }
  }

  /// Call user using the given call [data].
  void callWithData(VideoImCallDataModel data) {
    if (data.interlocutorId != authService.authUser!.id) {
      final newData = VideoImCallDataModel(
        interlocutorId: data.interlocutorId,
        interlocutorAvatarUrl: data.interlocutorAvatarUrl,
        interlocutorDisplayName: data.interlocutorDisplayName,
        role: VideoImCallRole.initiator,
        sessionId: generateSessionId(),
      );

      setActiveCallData(newData);
    }
  }

  /// Sets [newData] as current call data and returns true if there is no
  /// active call. If there is an active call, does nothing and returns false.
  @action
  void setActiveCallData(VideoImCallDataModel newData) {
    if (activeCall != null && onActiveCallChangedCallback != null) {
      onActiveCallChangedCallback!();
    }

    clearActiveCallData();

    activeCall = newData;

    removeLastOffer();
  }

  /// Discard current active call.
  @action
  void clearActiveCallData() {
    onActiveCallChangedCallback = null;
    onActiveCallAnswerNotificationCallback = null;
    onActiveCallCandidateNotificationCallback = null;
    onActiveCallErrorNotificationCallback = null;
    activeCall = null;
  }

  /// Send bye notification to the active interlocutor, then discard current
  /// active call.
  @action
  Future<VideoImApiResponseModel?> endActiveCall() async {
    if (activeCall != null) {
      final response = endCall(activeCall!);
      clearActiveCallData();

      return response;
    }

    return Future.value(null);
  }

  /// Remove the given [offer] from the offer stack.
  @action
  void removeOffer(VideoImCallDataModel offer) {
    offers = offers.where((element) => element != offer).toList();
  }

  /// Remove the last offer from the offer stack.
  @action
  void removeLastOffer() {
    if (offers.isNotEmpty) {
      removeOffer(offers.last);
    }
  }

  /// Send Video IM call offer to the given [userId].
  @action
  Future<VideoImApiResponseModel> sendOffer(
    int userId,
    String sessionId,
    RTCSessionDescription offer,
  ) async {
    isSendOfferPending = true;

    VideoImApiResponseModel response;

    try {
      response = await videoImService.sendNotification(
        userId,
        sessionId,
        offer.toMap(),
      );
    } catch (e) {
      isSendOfferPending = false;

      throw e;
    }

    isSendOfferPending = false;

    return response;
  }

  /// Process [notifications] received from the server.
  @action
  Future<void> processNotifications(
    List<VideoImNotificationModel> notifications,
  ) async {
    _updateVideoImPermissions();

    final unprocessedNotifications = notifications.where(
      (notification) => !_processedNotificationIds.contains(notification.id),
    );

    final unprocessedNotificationIds = unprocessedNotifications
        .map<int>((notification) => notification.id)
        .toList();

    final sessionId = activeCall != null
        ? activeCall!.sessionId
        : notifications.first.sessionId;

    // Mark received notifications.
    await videoImService.markNotificationsAsReceived(
      sessionId,
      unprocessedNotificationIds,
    );

    // Save processed notifications.
    _processedNotificationIds.addAll(unprocessedNotificationIds);

    notifications.forEach(
      (notification) {
        switch (notification.type) {
          case VideoImNotificationType.offer:
            _handleOffer(notification);
            break;

          case VideoImNotificationType.answer:
            _handleAnswer(notification);
            break;

          case VideoImNotificationType.candidate:
            _handleCandidate(notification);
            break;

          case VideoImNotificationType.creditsOut:
          case VideoImNotificationType.notSupported:
          case VideoImNotificationType.notPermitted:
          case VideoImNotificationType.declined:
          case VideoImNotificationType.blocked:
          case VideoImNotificationType.bye:
            _handleError(notification);
            break;
        }
      },
    );
  }

  /// Handle video call [offer].
  @action
  Future<void> _handleOffer(VideoImNotificationModel offer) async {
    final callData = VideoImCallDataModel(
      interlocutorId: offer.user.id!,
      interlocutorAvatarUrl: _getAvatarUrl(offer.user)!,
      interlocutorDisplayName: offer.user.userName!,
      role: VideoImCallRole.interlocutor,
      sessionId: offer.sessionId,
      offerDescription: RTCSessionDescription(
        offer.notificationBody['sdp'],
        offer.notificationBody['type'],
      ),
    );

    // Check call reception permission.
    if (receivePermission != null) {
      if (!receivePermission!.isAllowed) {
        // If the user cannot receive video calls, send not permitted
        // notification and discard the offer.
        await sendNotPermittedNotification(callData);

        return;
      }
    }

    if (activeCall != null) {
      // ignore offers from the logged in user and multiple offers from the same
      // user.
      if (offer.user.id == authService.authUser!.id ||
          activeCall!.interlocutorId == offer.user.id) {
        return;
      }
    }

    rootState.log('[video_im] new offer received');
    rootState.log('[video_im] offers:');

    // remove past offers from the calling user
    final newOffers = offers.where(
      (offer) => offer.interlocutorId != callData.interlocutorId,
    );

    // form new offer stack
    offers = [...newOffers, callData];

    rootState.log(offers);
  }

  /// Update Video IM-related permissions.
  @action
  void _updateVideoImPermissions() {
    callPermission = dashboardUserState.getUserPermission(_callPermissionName);

    receivePermission =
        dashboardUserState.getUserPermission(_receivePermissionName);

    timedCallPermission = dashboardUserState.getUserPermission(
      _timedCallPermissionName,
    );
  }

  /// Dispose of the allocated resources.
  void dispose() {
    _permissionsDisposer();
  }

  /// Send ICE [candidate] to the given [userId].
  Future<VideoImApiResponseModel> sendIceCandidate(
    int userId,
    RTCIceCandidate candidate,
  ) {
    return videoImService.sendNotification(
      userId,
      activeCall!.sessionId,
      _VideoImNotifications.withData(
        _VideoImNotifications.candidate,
        {
          'id': candidate.sdpMid,
          'label': candidate.sdpMLineIndex,
          'candidate': candidate.candidate,
        },
      ),
    );
  }

  /// Send out of credits notification to the interlocutor.
  Future<VideoImApiResponseModel> sendCreditsOutNotification(
    VideoImCallDataModel callData,
  ) {
    return videoImService.sendNotification(
      callData.interlocutorId,
      callData.sessionId,
      _VideoImNotifications.creditsOut,
    );
  }

  /// Send not permitted notification to the interlocutor.
  Future<VideoImApiResponseModel> sendNotPermittedNotification(
    VideoImCallDataModel callData,
  ) {
    return videoImService.sendNotification(
      callData.interlocutorId,
      callData.sessionId,
      _VideoImNotifications.notPermitted,
    );
  }

  /// Track Video IM timed call action. Should be called every minute.
  Future<dynamic> trackTimedCallAction() {
    return permissionsService.trackAction(
      group: _videoImActionGroupName,
      action: _videoImTimedCallActionName,
    );
  }

  /// Returns whether the call is tracked for the given [role].
  bool isCallTrackedForRole(VideoImCallRole role) {
    final trackingMode =
        rootState.getSiteSetting('videoim_track_credits_type', '');

    return (trackingMode == _VideoImCreditsTrackingMode.both) ||
        (trackingMode == _VideoImCreditsTrackingMode.initiator &&
            role == VideoImCallRole.initiator) ||
        (trackingMode == _VideoImCreditsTrackingMode.interlocutor &&
            role == VideoImCallRole.interlocutor);
  }

  /// Send [answer] data related to the given [call].
  Future<VideoImApiResponseModel> sendAnswer(
    VideoImCallDataModel call,
    RTCSessionDescription answer,
  ) {
    return videoImService.sendNotification(
      call.interlocutorId,
      call.sessionId,
      answer.toMap(),
    );
  }

  /// Block the interlocutor in the given [call].
  Future<VideoImApiResponseModel> blockCaller(VideoImCallDataModel call) async {
    await userService.blockUser(call.interlocutorId);

    return videoImService.sendNotification(
      call.interlocutorId,
      call.sessionId,
      _VideoImNotifications.declined,
    );
  }

  /// Decline the given [call].
  Future<VideoImApiResponseModel> declineCall(VideoImCallDataModel call) {
    return videoImService.sendNotification(
      call.interlocutorId,
      call.sessionId,
      _VideoImNotifications.declined,
    );
  }

  /// End the given [call] by sending a "bye" notification to the interlocutor.
  Future<VideoImApiResponseModel> endCall(VideoImCallDataModel call) {
    return videoImService.sendNotification(
      call.interlocutorId,
      call.sessionId,
      _VideoImNotifications.bye,
    );
  }

  /// Generate video IM session ID.
  String generateSessionId() {
    return randomService.string(prefix: 'im', minLength: 8);
  }

  /// Initialize Video IM-related permissions watcher.
  void _initPermissionsWatcher() {
    _permissionsDisposer = reaction(
      (_) => dashboardUserState.user,
      (dynamic _) => _updateVideoImPermissions(),
    );
  }

  /// Handle interlocutor [answer].
  void _handleAnswer(VideoImNotificationModel answer) {
    if (answer.sessionId == activeCall!.sessionId &&
        onActiveCallAnswerNotificationCallback != null) {
      onActiveCallAnswerNotificationCallback!(answer);
    }
  }

  /// Handle remote [candidate].
  void _handleCandidate(VideoImNotificationModel candidate) {
    final candidateInstance = RTCIceCandidate(
      candidate.notificationBody['candidate'],
      candidate.notificationBody['id'],
      candidate.notificationBody['label'],
    );

    if (activeCall == null) {
      // Store the candidates for later usage.
      storedCandidates.add(candidateInstance);
    } else if (candidate.sessionId == activeCall!.sessionId &&
        onActiveCallCandidateNotificationCallback != null) {
      onActiveCallCandidateNotificationCallback!(candidateInstance);
    }
  }

  /// Handle error [notification].
  void _handleError(VideoImNotificationModel notification) {
    if (activeCall == null) {
      return;
    }

    if (notification.sessionId != activeCall!.sessionId ||
        onActiveCallErrorNotificationCallback == null) {
      return;
    }

    String errorTranslationKey = '';

    switch (notification.type) {
      case VideoImNotificationType.creditsOut:
        errorTranslationKey = 'vim_mobile_call_ended_user_ran_out_credits';
        break;

      case VideoImNotificationType.notSupported:
        errorTranslationKey = 'vim_send_request_error_webrtc_not_supported';
        break;

      case VideoImNotificationType.notPermitted:
        errorTranslationKey = 'vim_does_not_accept_incoming_calls';
        break;

      case VideoImNotificationType.declined:
        errorTranslationKey = 'vim_request_declined';
        break;

      case VideoImNotificationType.blocked:
        errorTranslationKey = 'vim_request_blocked';
        break;

      case VideoImNotificationType.bye:
        errorTranslationKey = 'vim_session_closed';
        break;
    }

    onActiveCallErrorNotificationCallback!(
      notification.type,
      errorTranslationKey,
    );
  }

  /// Get avatar URL for the given [user].
  ///
  /// Returns default avatar URL if the provided [user] doesn't have an avatar.
  String? _getAvatarUrl(UserModel user) {
    return user.avatar?.url ?? rootState.getSiteSetting('defaultAvatar', '');
  }
}
