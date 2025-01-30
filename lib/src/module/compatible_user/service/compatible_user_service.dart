
import '../../../app/service/http_service.dart';
import 'model/compatible_user_model.dart';

class CompatibleUserService {
  final HttpService httpService;

  CompatibleUserService({
    required this.httpService,
  });

  Future<List<CompatibleUserModel>> loadUsers() async {
    final List users = await this.httpService.get('compatible-users');

    final List<CompatibleUserModel> userList =
        users.map((user) => CompatibleUserModel.fromJson(user)).toList();

    return userList;
  }
}
