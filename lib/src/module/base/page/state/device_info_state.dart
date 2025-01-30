
import '../../../../app/service/device_info_service.dart';

class DeviceInfoState {
  final DeviceInfoService deviceInfoService;

  String? _deviceUuid;

  /// Unique device ID.
  Future<String?> get uuid async {
    if (_deviceUuid == null) {
      _deviceUuid = await deviceInfoService.getDeviceUuid();
    }

    return _deviceUuid;
  }

  /// Platform name as string.
  String get platform => deviceInfoService.getPlatform();

  DeviceInfoState({
    required this.deviceInfoService,
  });
}
