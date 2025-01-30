import 'package:browser_detector/browser_detector.dart';

/// Provides information about the host browser in formats suitable for usage
/// with error various reporting services.
class BrowserInfoService {
  final BrowserDetector browserDetector;

  static const _browsers = const <Browsers, String>{
    Browsers.chrome: 'chrome',
    Browsers.edge: 'edge',
    Browsers.firefox: 'firefox',
    Browsers.safari: 'safari',
    Browsers.unknown: 'unknown',
  };

  static const _platforms = const <Platforms, String>{
    Platforms.android: 'android',
    Platforms.iOS: 'ios',
    Platforms.iPadOS: 'ipados',
    Platforms.linux: 'linux',
    Platforms.macOS: 'macos',
    Platforms.windows: 'windows',
    Platforms.unknown: 'unknown',
  };

  static const _engines = const <Engines, String>{
    Engines.blink: 'blink',
    Engines.gecko: 'gecko',
    Engines.webkit: 'webkit',
    Engines.unknown: 'unknown'
  };

  /// Host browser name.
  String get browser => _browsers[browserDetector.browser.type] ?? 'unknown';

  /// Name of the platform the host browser is running on.
  String get platform => _platforms[browserDetector.platform.type] ?? 'unknown';

  /// Name of the engine the host browser is using.
  String get engine => _engines[browserDetector.engine.type] ?? 'unknown';

  const BrowserInfoService({
    required this.browserDetector,
  });

  /// Get host browser info as a map. The resulting map contains the following
  /// fields:
  ///
  /// * `browser` - name of the browser, e.g. `chrome`, `firefox`, etc.
  ///
  /// * `platform` - name of the platform the browser is running on, e.g.
  /// `windows`, `linux`, etc.
  ///
  /// * `engine` - name of the engine the browser is using, e.g. `blink`,
  /// `gecko`, etc.
  Map<String, String> getBrowserInfo() {
    return {
      'browser': browser,
      'platform': platform,
      'engine': engine,
    };
  }
}
