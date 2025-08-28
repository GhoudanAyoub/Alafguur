import 'package:sprintf/sprintf.dart';

import '../../../app/service/http_service.dart';

class BookmarkProfileService {
  final HttpService httpService;
  final String basicBookmarkProfileRequestName = 'bookmark_profile';

  BookmarkProfileService({
    required this.httpService,
  });

  Future<List?> loadBookmarks() async {
    return await this.httpService.get('bookmarks') as List?;
  }

  /// add a user in the bookmark list
  Future<void> bookmarkProfile(int? userId) async {
    // cancel a previous request
    httpService.cancelRequestByName(_getRequestName(userId));

    await httpService.post(
      'bookmarks',
      data: {
        'userId': userId,
      },
      requestName: _getRequestName(userId),
    );
  }

  /// delete a user from the bookmark list
  Future<void> unbookmarkProfile(int? userId) async {
    // cancel a previous request
    httpService.cancelRequestByName(_getRequestName(userId));

    await httpService.delete(
      'bookmarks/users/$userId',
      requestName: _getRequestName(userId),
    );
  }

  String? _getRequestName(int? userId) {
    return sprintf('%s_%s', [basicBookmarkProfileRequestName, userId]);
  }
}
