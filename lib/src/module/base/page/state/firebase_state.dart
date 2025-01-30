import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../service/firebase_service.dart';

/// Supported Push notification types.
class PushNotificationType {
  static const String matchedUser = 'matchedUser';
  static const String message = 'message';
}

typedef OnMessageCallback = void Function(RemoteMessage);
typedef OnFcmTokenRefreshCallback = void Function(String);

class FirebaseState {
  final FirebaseService firebaseService;

  FirebaseApp? _app;
  FirebaseMessaging? _messaging;

  /// Global [FirebaseApp] instance.
  FirebaseApp? get app => _app;

  /// Global [FirebaseMessaging] instance.
  FirebaseMessaging? get messaging => _messaging;

  FirebaseState({
    required this.firebaseService,
  });

  /// Initialize Firebase.
  Future<void> init() async {
    await _initializeFirebase();
    await _initializeFirebaseMessaging();
  }

  /// Set [onMessageCallback] to handle the app opened by tapping a push
  /// notification.
  StreamSubscription<RemoteMessage> setOnMessageCallback(
    OnMessageCallback onMessageCallback,
  ) {
    return FirebaseMessaging.onMessageOpenedApp
        .asBroadcastStream()
        .listen(onMessageCallback);
  }

  /// Set [onFcmTokenRefreshCallback] to handle the FCM token refresh event.
  StreamSubscription<String> setOnFcmTokenRefreshCallback(
    OnFcmTokenRefreshCallback onFcmTokenRefreshCallback,
  ) {
    return _messaging!.onTokenRefresh.listen(onFcmTokenRefreshCallback);
  }

  /// Returns FCM device token using the provided [vapidKey]. Returns null if
  /// the Firebase Cloud Messaging is not initialized at the moment of call.
  Future<String?> getFcmToken({
    required String vapidKey,
  }) {
    if (_messaging == null) {
      return Future.value(null);
    }

    return _messaging!.getToken(vapidKey: vapidKey);
  }

  /// Register device to receive Push notifications.
  ///
  /// The device is identified by its [deviceId]. The provided [fcmToken] will
  /// be used to identify the device within the FCM infrastructure and the
  /// [platform] identifier will determine the appropriate delivery method.
  Future<dynamic> registerDevice({
    required String deviceId,
    required String fcmToken,
    required String platform,
    String? language,
  }) {
    return firebaseService.registerDevice(
      deviceId: deviceId,
      fcmToken: fcmToken,
      platform: platform,
      language: language,
    );
  }

  /// Unregister device by its [deviceId]. This prevents the device from
  /// receiving Push notifications.
  Future<dynamic> unregisterDevice({
    required String? deviceId,
  }) {
    return firebaseService.unregisterDevice(deviceId: deviceId);
  }

  /// Initialize Firebase.
  Future<void> _initializeFirebase() async {
    if (!kIsWeb && _app == null) {
      _app = await Firebase.initializeApp();
    }
  }

  /// Initialize Firebase Cloud Messaging.
  Future<void> _initializeFirebaseMessaging() async {
    if (_messaging != null) {
      return;
    }

    _messaging = FirebaseMessaging.instance;

    // There's no need to request permission here if running in the PWA mode
    // because the permission was already requested during the app startup.
    if (!kIsWeb && Platform.isIOS) {
      final permission = await _messaging!.requestPermission();

      if (permission.authorizationStatus == AuthorizationStatus.denied) {
        _messaging = null;
      }
    }
  }
}
