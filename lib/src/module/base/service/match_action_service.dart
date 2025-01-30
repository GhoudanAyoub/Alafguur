import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import '../../../app/service/http_service.dart';

const USER_LIKE_PRESSED = 'user_like_pressed';
const USER_DISLIKE_PRESSED = 'user_dislike_pressed';

class MatchActionService {
  final HttpService httpService;
  final SharedPreferences sharedPreferences;
  final String basicBookmarkProfileRequestName = 'match_profile';

  MatchActionService({
    required this.httpService,
    required this.sharedPreferences,
  });

  bool? get isUserLikePressed => sharedPreferences.getBool(USER_LIKE_PRESSED);

  void setIsUserLikePressed(bool value) =>
      sharedPreferences.setBool(USER_LIKE_PRESSED, value);

  bool? get isUserDisLikePressed =>
      sharedPreferences.getBool(USER_DISLIKE_PRESSED);

  void setIsUserDisLikePressed(bool value) =>
      sharedPreferences.setBool(USER_DISLIKE_PRESSED, value);

  Future<void> likeUser(int? userId) async {
    // cancel a previous request
    httpService.cancelRequestByName(_getRequestName(userId));

    await httpService.post(
      'math-actions/user',
      data: {
        'userId': userId,
        'type': 'like',
      },
      requestName: _getRequestName(userId),
    );
  }

  Future<void> dislikeUser(int? userId) async {
    // cancel a previous request
    httpService.cancelRequestByName(_getRequestName(userId));

    await httpService.post(
      'math-actions/user',
      data: {
        'userId': userId,
        'type': 'dislike',
      },
      requestName: _getRequestName(userId),
    );
  }

  Future<void> deleteMatch(int? userId) async {
    // cancel a previous request
    httpService.cancelRequestByName(_getRequestName(userId));

    await httpService.delete(
      'math-actions/user/$userId',
      requestName: _getRequestName(userId),
    );
  }

  String? _getRequestName(int? userId) {
    return sprintf('%s_%s', [basicBookmarkProfileRequestName, userId]);
  }
}
