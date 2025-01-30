import 'package:flutter_webrtc/flutter_webrtc.dart';

enum VideoImCallRole {
  initiator,
  interlocutor,
}

class VideoImCallDataModel {
  /// Interlocutor user ID.
  final int interlocutorId;

  /// Interlocutor avatar URL.
  final String interlocutorAvatarUrl;

  /// Interlocutor display name. Can be changed in the Skadate settings.
  final String interlocutorDisplayName;

  /// Current user's role in the call.
  final VideoImCallRole role;

  /// Video IM session ID.
  final String sessionId;

  /// Optional WebRTC offer description.
  final RTCSessionDescription? offerDescription;

  /// Optional candidates received with the offer.
  List<RTCIceCandidate>? candidates;

  VideoImCallDataModel({
    required this.interlocutorId,
    required this.interlocutorAvatarUrl,
    required this.interlocutorDisplayName,
    required this.role,
    required this.sessionId,
    this.offerDescription,
    this.candidates,
  });

  @override
  String toString() {
    final sb = new StringBuffer('(');

    if (role == VideoImCallRole.initiator) {
      sb.write('Call offer to user ID ');
    } else {
      sb.write('Call offer from user ID ');
    }

    sb.write('$interlocutorId ["$interlocutorDisplayName"])');

    return sb.toString();
  }
}
