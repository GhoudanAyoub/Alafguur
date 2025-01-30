import 'dart:typed_data';

class PhotoViewerModel {
  final String? url;
  final Uint8List? bytes;

  PhotoViewerModel({
    this.url,
    this.bytes,
  });
}
