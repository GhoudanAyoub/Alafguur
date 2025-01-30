import 'dart:io';

import 'package:application/src/module/base/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/service/firebase_auth_service.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../service/login_service.dart';

part 'login_state.g.dart';

class LoginState = _LoginState with _$LoginState;

abstract class _LoginState with Store {
  final LoginService loginService;
  final FirebaseAuthService firebaseAuthService;
  final RootState rootState;
  final SharedPreferences sharedPreferences;
  final UserService userService;

  final String _pwaLoginAttemptedSharedPreferencesKey = 'pwa_login_attempted';

  OnDeepLinkCallback? _deepLinkCallback;

  late ReactionDisposer _deepLinkWatcherCancellation;

  @observable
  bool loading = false;

  @observable
  bool firebaseLoading = false;

  @observable
  bool? redirectToSubscribe = null;

  @observable
  bool? showingPopup = null;

  _LoginState({
    required this.loginService,
    required this.firebaseAuthService,
    required this.rootState,
    required this.sharedPreferences,
    required this.userService,
  });

  /// pre initialize (watchers, etc)
  init() {
    _deepLinkCallback?.call(rootState.deepLink);

    _initDeepLinkWatcher();
  }

  void dispose() {
    _deepLinkWatcherCancellation();
  }

  Future<void> clearCredentials() async {
    await rootState.cleanAuthCredentials(unregisterDevice: false);
  }

  @action
  Future<bool> authenticate(Map<String, dynamic> formValues) async {
    loading = true;

    final token = await loginService.login(formValues);
    final isAuthenticated = token != null;

    if (isAuthenticated) {
      rootState.setAuthenticated(token!);
    }

    if (isAuthenticated && rootState.isPluginAvailable('redirecttosubscribe')) {
      final server_rts = await userService.redirectToSubscribe();
      redirectToSubscribe = server_rts;
      sharedPreferences.setBool(REDIRECT_TO_SUBSCRIBE, server_rts);
    }

    if (isAuthenticated && rootState.isPluginAvailable('popupmessages')) {
      final server_sp = await userService.showingPopup();
      showingPopup = server_sp;
      sharedPreferences.setBool(SHOWING_POPUP, server_sp);
    }

    loading = false;

    return isAuthenticated;
  }

  void setDeeplinkCallback(OnDeepLinkCallback deepLinkCallback) {
    _deepLinkCallback = deepLinkCallback;
  }

  List<FormElementModel> getFormElements() {
    return loginService.getFormElements();
  }

  String? get customLogo => rootState.getSiteSetting('themeLogo', null);

  int get customLogoWidth => rootState.getSiteSetting('themeLogoWidth', 0);

  String? get customBackground =>
      rootState.getSiteSetting('themeBackground', null);

  bool isGoogleSignInAllowed() {
    return _getAuthProviders().contains('google.com');
  }

  bool isFacebookSignInAllowed() {
    return _getAuthProviders().contains('facebook.com');
  }

  // TODO: replace flutter_twitter_login
  // bool isTwitterSignInAllowed() {
  //   return _getAuthProviders().contains('twitter.com');
  // }

  bool isAppleSignInAllowed() {
    return kIsWeb && _getAuthProviders().contains('apple.com') ||
        _getAuthProviders().contains('apple.com') && !Platform.isAndroid;
  }

  bool isCustomSignInAllowed() {
    return isGoogleSignInAllowed() ||
        isFacebookSignInAllowed() ||
        // isTwitterSignInAllowed() ||
        isAppleSignInAllowed();
  }

  bool isPwaLoginAttempted() {
    return sharedPreferences
        .containsKey(_pwaLoginAttemptedSharedPreferencesKey);
  }

  Future<String?> getPwaAuthenticatedProviderId() async {
    await sharedPreferences.remove(_pwaLoginAttemptedSharedPreferencesKey);
    UserCredential? credentials;

    try {
      credentials = await firebaseAuthService.getPwaRedirectAuthResult();
    } catch (error) {
      rootState.log('[login_state+get_pwa_authenticated_provider_id] $error');
    }

    if (credentials == null) {
      return null;
    }

    await _firebaseAuthenticate(credentials);

    return credentials.credential!.providerId;
  }

  @action
  Future<bool?> googleSignIn() async {
    try {
      if (rootState.isPwaMode) {
        await sharedPreferences.setBool(
            _pwaLoginAttemptedSharedPreferencesKey, true);
      }

      final authResult = await firebaseAuthService.googleSignIn();

      if (authResult == null) {
        return null;
      }

      return _firebaseAuthenticate(authResult);
    } catch (error) {
      rootState.log('[login_state+google_sign_in] $error');
    }

    return false;
  }

  // TODO: replace flutter_twitter_login
  // @action
  // Future<bool?> twitterSignIn() async {
  //   try {
  //     if (rootState.isPwaMode) {
  //       await sharedPreferences.setBool(
  //           _pwaLoginAttemptedSharedPreferencesKey, true);
  //     }

  //     final authResult = await firebaseAuthService.twitterSignIn();

  //     if (authResult == null) {
  //       return null;
  //     }

  //     return _firebaseAuthenticate(authResult);
  //   } catch (error) {
  //     rootState.log('[login_state+twitter_sign_in] $error');
  //   }

  //   return false;
  // }

  @action
  Future<bool?> faceBookSignIn() async {
    try {
      if (rootState.isPwaMode) {
        await sharedPreferences.setBool(
            _pwaLoginAttemptedSharedPreferencesKey, true);
      }

      final authResult = await firebaseAuthService.facebookSignIn();

      if (authResult == null) {
        return null;
      }

      return _firebaseAuthenticate(authResult);
    } catch (error) {
      rootState.log('[login_state+facebook_sign_in] $error');
    }

    return false;
  }

  @action
  Future<bool?> appleSignIn() async {
    try {
      if (rootState.isPwaMode) {
        await sharedPreferences.setBool(
            _pwaLoginAttemptedSharedPreferencesKey, true);
      }

      final authResult = await firebaseAuthService.appleSignIn();

      if (authResult == null) {
        return null;
      }

      return _firebaseAuthenticate(authResult);
    } catch (error) {
      rootState.log('[login_state+apple_sign_in] $error');
    }

    return false;
  }

  Future<bool> _firebaseAuthenticate(UserCredential userCredential) async {
    firebaseLoading = true;

    final token = await loginService.firebaseLogin(userCredential);
    final isAuthenticated = token != null;

    if (isAuthenticated) {
      rootState.setAuthenticated(token!);
    }

    if (isAuthenticated && rootState.isPluginAvailable('redirecttosubscribe')) {
      final server_rts = await userService.redirectToSubscribe();
      redirectToSubscribe = server_rts;
      sharedPreferences.setBool(REDIRECT_TO_SUBSCRIBE, server_rts);
    }

    if (isAuthenticated && rootState.isPluginAvailable('popupmessages')) {
      final server_sp = await userService.showingPopup();
      redirectToSubscribe = server_sp;
      sharedPreferences.setBool(SHOWING_POPUP, server_sp);
    }

    firebaseLoading = false;

    return isAuthenticated;
  }

  void _initDeepLinkWatcher() {
    _deepLinkWatcherCancellation =
        reaction((_) => rootState.deepLink, (String? link) {
      _deepLinkCallback?.call(link);
    });
  }

  List _getAuthProviders() => rootState.getSiteSetting('authProviders', []);
}
