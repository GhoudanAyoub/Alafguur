
import '../../../app/service/http_service.dart';
import '../../base/service/model/user_model.dart';

class ProfileService {
  final HttpService httpService;

  ProfileService({
    required this.httpService,
  });

  /// load profile
  Future<UserModel> loadProfile(
    int? id, {
    List<String>? extraRelations,
  }) async {
    final result = await httpService.get(
      'users/$id',
      queryParameters: {
        'with[]': [
          'avatar',
          'matchAction',
          'viewQuestions',
          ...extraRelations ?? []
        ],
      },
    );

    return UserModel.fromJson(result);
  }
}
