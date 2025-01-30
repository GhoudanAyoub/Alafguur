import 'dart:typed_data';

enum EditPhotoUnitType { avatar, photo }

class EditPhotoUnitModel {
  final dynamic id;
  final String? url;
  final String? bigUrl;
  final bool? isPending;
  final Uint8List? bytes;
  final EditPhotoUnitType? type;
  final bool? isActive;

  EditPhotoUnitModel({
    this.id,
    this.url,
    this.bigUrl,
    this.isPending,
    this.bytes,
    this.type,
    this.isActive = true,
  });
}
