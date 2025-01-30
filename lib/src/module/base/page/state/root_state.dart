import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

import '../../../../app/service/auth_service.dart';
import '../../../../app/service/logger_service.dart';
import '../../../../app/service/model/logger_user_data_model.dart';
import '../../service/root_service.dart';
import '../../utility/debug_logger_utility.dart';
import 'device_info_state.dart';
import 'firebase_state.dart';

part 'root_state.g.dart';

typedef OnErrorCallback = Function(dynamic error);
typedef OnDeepLinkCallback = Function(String? link);
typedef OnOnlineCallback = Function(bool online);

class RootState = _RootState with _$RootState;

abstract class _RootState with Store {
  final RootService rootService;
  final AuthService authService;
  final LoggerService loggerService;
  final DebugLoggerUtility debugLoggerUtility;
  final FirebaseState firebaseState;
  final DeviceInfoState deviceInfoState;
  final bool isPwaMode;

  @observable
  dynamic error;

  @observable
  StackTrace? stackTrace;

  @observable
  AppLifecycleState? applicationState;

  @observable
  bool isOnline = true;

  @observable
  bool isApplicationLoaded = false;

  @observable
  bool? isAuthenticated;

  @observable
  bool isServerUpdatesLoaded = false;

  @observable
  Map<String, dynamic> serverUpdates = {};

  @observable
  Map<String, dynamic> siteSettings = {};

  @observable
  String? deepLink;

  @observable
  late AppLinks _appLinks;

  OnErrorCallback? _errorCallback;
  OnOnlineCallback? _onlineCallback;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int _siteConfigLastUpdateTime = 0;
  final String _serverUpdatesConfigsChannel = 'configs';
  Map<String, int> _serverUpdatesLastUpdateTime = {};
  int _serverUpdatesDelay = 2000;
  bool _isServerUpdatesRunning = false;

  final String _appTinderMode = 'tinder';
  final String _appBrowseMode = 'browse';
  final String _appBothMode = 'both';

  _RootState({
    required this.rootService,
    required this.authService,
    required this.loggerService,
    required this.debugLoggerUtility,
    required this.firebaseState,
    required this.deviceInfoState,
    required this.isPwaMode,
  }) {
    isAuthenticated = authService.isAuthenticated;
  }

  @action
  void setAuthenticated(String token) {
    authService.setAuthenticated(token);
    isAuthenticated = true;
    _siteConfigLastUpdateTime = 0;
  }

  @action
  Future<void> cleanAuthCredentials({
    bool unregisterDevice = true,
  }) async {
    if (unregisterDevice) {
      firebaseState.unregisterDevice(deviceId: await deviceInfoState.uuid);
    }

    authService.clearToken();
    cleanAppErrors();
    isAuthenticated = false;
    restartServerUpdates(cleanDataHashes: true);
  }

  @action
  void cleanAppErrors() {
    error = null;
    stackTrace = null;
  }

  @action
  Future<void> loadResources() async {
    try {
      siteSettings = (await rootService.loadSettings())!;
    } catch (requestError, requestStackTrace) {
      error = requestError;
      stackTrace = requestStackTrace;
    }
  }

  @action
  void init() {
    // check if the all needed resources were loaded
    if (error == null) {
      isApplicationLoaded = true;
    }

    // start watchers
    // _initInternetConnectionWatcher();
    _initServerUpdatesWatcher();
    _initAuthWatcher();
    _initConfigWatcher();
    _initErrorWatcher();
    _initDeepLinksWatcher();
    _initApplicationStateWatcher();
  }

  void restartServerUpdates({
    bool cleanDataHashes = false,
  }) {
    rootService.cancelServerUpdatesRequest(
      cleanDataHashes: cleanDataHashes,
    );

    _isServerUpdatesRunning = false;
  }

  /// Print a debug [message].
  void log(dynamic message) {
    debugLoggerUtility.log(
      getSiteSetting('isDebugMode', true),
      message,
    );
  }

  /// extract and return server updates by it's channel name
  dynamic getServerUpdates(String channel) {
    if (serverUpdates.containsKey(channel)) {
      return serverUpdates[channel];
    }
  }

  /// return the server updates channel's updating time
  int? getServerUpdatesLastUpdateTime(String channel) {
    if (_serverUpdatesLastUpdateTime.containsKey(channel)) {
      return _serverUpdatesLastUpdateTime[channel];
    }

    return null;
  }

  void setErrorCallback(OnErrorCallback errorCallback) {
    _errorCallback = errorCallback;
  }

  void setOnlineCallback(OnOnlineCallback? onlineCallback) {
    _onlineCallback = onlineCallback;
  }

  bool isPluginAvailable(String pluginKey) =>
      getSiteSetting('activePlugins', []).contains(pluginKey);

  // get a site setting
  T getSiteSetting<T>(String settingName, T defaultValue) {
    if (siteSettings.containsKey(settingName) &&
        siteSettings[settingName] != null) {
      return siteSettings[settingName]!;
    }

    return defaultValue;
  }

  /// True if the current user is logged in as admin.
  bool get isLoggedInAsAdmin => authService.authUser!.isAdmin;

  /// True if the demo mode is currently activated.
  bool get isDemoModeActivated => getSiteSetting('isDemoModeActivated', false);

  bool get isAppTinderMode =>
      getSiteSetting('searchMode', '') == _appTinderMode;

  bool get isAppBrowseMode =>
      getSiteSetting('searchMode', '') == _appBrowseMode;

  bool get isAppBothMode => getSiteSetting('searchMode', '') == _appBothMode;

  /// watch the auth state
  void _initAuthWatcher() {
    reaction(
      (_) => isAuthenticated,
      (bool? isAuthenticated) {
        // whenever the auth state is changed we relaunch the server updates
        serverUpdates = {};
        isServerUpdatesLoaded = false;
        rootService.cancelServerUpdatesRequest();

        // Update Sentry context with user data.
        if (isAuthenticated != null && isAuthenticated) {
          final userData = authService.authUser!;

          loggerService.setUserData(
            LoggerUserDataModel(
              id: userData.id,
              username: userData.name,
              email: userData.email,
            ),
          );
        } else {
          loggerService.setUserData(null);
        }
      },
    );
  }

  void _initApplicationStateWatcher() {
    reaction(
      (_) => applicationState,
      (state) {
        restartServerUpdates();
      },
    );
  }

  /// watch configs updates
  @action
  void _initConfigWatcher() {
    reaction(
      (_) => serverUpdates,
      (dynamic _) {
        int? lastChannelUpdateTime =
            getServerUpdatesLastUpdateTime(_serverUpdatesConfigsChannel);
        final newSettings = getServerUpdates(_serverUpdatesConfigsChannel);

        // we have gotten updated configs
        if (lastChannelUpdateTime != null &&
            lastChannelUpdateTime > _siteConfigLastUpdateTime &&
            newSettings != null) {
          _siteConfigLastUpdateTime = lastChannelUpdateTime;
          siteSettings = newSettings;
        }
      },
    );
  }

  /// watch for errors
  void _initErrorWatcher() {
    reaction(
      (_) => error,
      (dynamic error) {
        if (error != null && _errorCallback != null) {
          _errorCallback!(error);
        }
      },
    );
  }

  @action
  Future<void> _initDeepLinksWatcher() async {
    if (kIsWeb) {
      return;
    }

    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((link) {
      deepLink = link.path;
    });
  }

  /// watch the server updates
  void _initServerUpdatesWatcher() {
    // periodically get server updates
    Timer.periodic(
      Duration(milliseconds: _serverUpdatesDelay),
      (_) {
        if (!_isServerUpdatesRunning &&
            isOnline &&
            error == null &&
            (applicationState == null ||
                applicationState == AppLifecycleState.resumed)) {
          _checkServerUpdates();
        }
      },
    );
  }

  Future<dynamic> ping() async {
    return await rootService.pingApi();
  }

  /// watch the internet status
  void _initInternetConnectionWatcher() {
    Connectivity().onConnectivityChanged.listen(
          (ConnectivityResult result) {
        _handleConnectivityChange(result);
      } as void Function(List<ConnectivityResult> event)?,
    );
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      // No connection
      isOnline = false;
      _onlineCallback?.call(isOnline);
      print("No internet connection.");
      return;
    }

    try {
      await rootService.pingApi(); // Make sure pingApi handles timeouts or failures
      isOnline = true;
    } catch (error) {
      isOnline = false;
      print("Error occurred while pinging API: $error");
    } finally {
      _onlineCallback?.call(isOnline);
    }
  }

  @action
  Future<void> _checkServerUpdates() async {
    _isServerUpdatesRunning = true;

    final newUpdates = await rootService.getServerUpdates();

    if (newUpdates != null) {
      // merge server updates and save the update time for each channel
      if (newUpdates.length != 0) {
        final mergedUpdates = {
          ...serverUpdates,
        };

        newUpdates.forEach(
          (key, value) {
            mergedUpdates[key] = value;
            _serverUpdatesLastUpdateTime[key] =
                DateTime.now().millisecondsSinceEpoch;
          },
        );

        serverUpdates = mergedUpdates;
      }

      isServerUpdatesLoaded = true;
    }

    _isServerUpdatesRunning = false;
  }
}
