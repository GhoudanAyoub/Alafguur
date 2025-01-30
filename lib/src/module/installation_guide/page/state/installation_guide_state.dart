import 'package:browser_detector/browser_detector.dart';
import 'package:mobx/mobx.dart';

part 'installation_guide_state.g.dart';

class InstallationGuideState = _InstallationGuideState
    with _$InstallationGuideState;

abstract class _InstallationGuideState with Store {
  final BrowserDetector browserDetector;
  String? _platform;

  _InstallationGuideState({
    required this.browserDetector,
  });

  String? get platform {
    if (_platform != null) {
      return _platform;
    }

    _platform = browserDetector.platform.isIOS ? 'ios' : 'android';

    return _platform;
  }
}
