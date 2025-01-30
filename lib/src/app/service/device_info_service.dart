import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'browser_info_service.dart';
import 'random_service.dart';

/// Platform names.
class _Platforms {
  static const android = 'android';
  static const iOS = 'ios';
  static const browser = 'browser';
  static const unknown = 'unknown';
}

/// Provides system information about the host device.
class DeviceInfoService {
  final DeviceInfoPlugin deviceInfoPlugin;
  final RandomService randomService;
  final BrowserInfoService browserInfoService;

  /// Saved Android device info for faster access. Android device info should be
  /// retrieved through the [androidDeviceInfo] property.
  AndroidDeviceInfo? _androidDeviceInfo;

  /// Saved iOS device info for faster access. iOS device info should be
  /// retrieved using the [iosDeviceInfo] property.
  IosDeviceInfo? _iosDeviceInfo;

  /// Android device info.
  Future<AndroidDeviceInfo> get androidDeviceInfo async {
    if (_androidDeviceInfo == null) {
      _androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    }

    return _androidDeviceInfo!;
  }

  /// iOS device info.
  Future<IosDeviceInfo> get iosDeviceInfo async {
    if (_iosDeviceInfo == null) {
      _iosDeviceInfo = await deviceInfoPlugin.iosInfo;
    }

    return _iosDeviceInfo!;
  }

  DeviceInfoService({
    required this.deviceInfoPlugin,
    required this.randomService,
    required this.browserInfoService,
  });

  /// Get host device UUID. Returns a unique device ID if running on Android or
  /// iOS, random string if running as PWA and null if running on any other
  /// platform.
  Future<String> getDeviceUuid() async {
    if (kIsWeb) {
      return Future.value(randomService.string(prefix: 'pwa'));
    } else if (Platform.isAndroid) {
      final data = await androidDeviceInfo;
      return data.id;
    } else if (Platform.isIOS) {
      final data = await iosDeviceInfo;
      return data.identifierForVendor!;
    }

    return Future.value('');
  }

  /// Returns a map containing the host device info. Contents of the map depend
  /// on the platform the app is running on.
  ///
  /// The returned map can be easily sent to the server without any specific
  /// serialization.
  Future<Map<String, dynamic>> getDeviceInfoMap() async {
    final result = {
      'platform': getPlatform(),
    };

    if (kIsWeb) {
      final browserInfo = browserInfoService.getBrowserInfo();

      final platformInfo = {
        'os': browserInfo['platform'],
        'browser': browserInfo['browser'],
        'engine': browserInfo['engine'],
      };

      return {
        ...result,
        ...platformInfo,
      };
    } else if (Platform.isAndroid) {
      return {
        ...result,
        ...await _getAndroidDeviceInfoMap(),
      };
    } else if (Platform.isIOS) {
      return {
        ...result,
        ...await _getIosDeviceInfoMap(),
      };
    }

    return result;
  }

  /// Get platform name as string.
  String getPlatform() {
    if (kIsWeb) {
      return _Platforms.browser;
    } else if (Platform.isAndroid) {
      return _Platforms.android;
    } else if (Platform.isIOS) {
      return _Platforms.iOS;
    } else {
      return _Platforms.unknown;
    }
  }

  /// Returns a map containing information about the Android device the app is
  /// running on.
  Future<Map<String, dynamic>> _getAndroidDeviceInfoMap() async {
    final androidInfo = await androidDeviceInfo;

    return {
      'release': androidInfo.version.release,
      'sdkInt': androidInfo.version.sdkInt,
      'manufacturer': androidInfo.manufacturer,
      'brand': androidInfo.brand,
      'model': androidInfo.model,
      'product': androidInfo.product,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
    };
  }

  /// Returns a map containing information about the iOS device the app is
  /// running on.
  Future<Map<String, dynamic>> _getIosDeviceInfoMap() async {
    final iosInfo = await iosDeviceInfo;

    return {
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'model': iosInfo.model,
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
    };
  }
}
