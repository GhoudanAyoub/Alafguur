
import '../../../app/service/http_service.dart';
import '../../base/service/model/user_avatar_model.dart';

class EditPhotoService {
  final HttpService httpService;

  EditPhotoService({
    required this.httpService,
  });

  deleteAvatar(int? id) {
    this.httpService.delete('avatars/$id');
  }

  deletePhoto(int? id) {
    this.httpService.delete('photos/$id');
  }

  Future<UserAvatarModel> makePhotoAsAvatar(int? id) async {
    final response = await this.httpService.put('photos/$id/setAsAvatar');

    return UserAvatarModel.fromJson(response);
  }
}
