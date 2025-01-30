

enum ProfilePhotoUnitType { avatar, photo }

class ProfilePhotoUnitModel {
  final String url;
  final int? id;
  final ProfilePhotoUnitType type;
  final bool? isActive;

  ProfilePhotoUnitModel({
    required this.type,
    required this.url,
    this.id,
    this.isActive = true,
  });
}
