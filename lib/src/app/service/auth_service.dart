import 'package:application/src/module/base/service/user_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exception/auth/auth_exception.dart';
import 'model/auth_user_model.dart';

const AUTH_TOKEN = 'auth_token';

class AuthService {
  final SharedPreferences sharedPreferences;

  /// Raw JWT
  String? _authToken;

  /// Decoded token data
  AuthUserModel? _authUser;

  /// Construct the auth service and attempt to retrieve the token from cache.
  /// Cached token will be removed if it is invalid.
  AuthService({
    required this.sharedPreferences,
  }) {
    _authToken = sharedPreferences.getString(AUTH_TOKEN);

    if (_authToken == null) {
      clearToken();
      return;
    }

    try {
      final decodedToken = JwtDecoder.decode(_authToken!);
      _authUser = AuthUserModel.fromJson(decodedToken);
    } on FormatException {
      clearToken();
    }
  }

  /// Decode the provided [token] and transition to the authenticated state,
  /// replace the cached token with the new one. Throws [AuthException] if the
  /// token is invalid.
  void setAuthenticated(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);

      _authToken = token;
      _authUser = AuthUserModel.fromJson(decodedToken);
      sharedPreferences.setString(AUTH_TOKEN, token);
    } on FormatException {
      throw AuthException('Invalid auth token.');
    }
  }

  /// Reset authentication state and remove the token from cache logging the
  /// user out.
  Future<void> clearToken() async {
    _authToken = null;
    _authUser = null;

    await sharedPreferences.remove(AUTH_TOKEN);
    await sharedPreferences.remove(REDIRECT_TO_SUBSCRIBE);
    await sharedPreferences.remove(SHOWING_POPUP);
  }

  /// User data retrieved from the token
  AuthUserModel? get authUser => this._authUser;

  /// Is app in the authenticated state
  bool get isAuthenticated => _authToken != null;

  /// Raw token data
  String? get authToken => _authToken;
}
