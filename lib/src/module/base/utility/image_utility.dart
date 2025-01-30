import 'dart:typed_data';

import 'package:mime/mime.dart';

class ImageUtility {
  Map<String, String> get allowedMimeTypes => {
        'image/jpg': 'jpg',
        'image/jpeg': 'jpg',
        'image/png': 'png',
      };

  bool isValidImage(String? mimeType) {
    return mimeType != null && allowedMimeTypes.containsKey(mimeType);
  }

  String? getMimeType(
    String path,
    Uint8List headerBytes,
  ) {
    return lookupMimeType(path, headerBytes: headerBytes);
  }

  String? getImageExtension(String mimeType) {
    if (allowedMimeTypes.containsKey(mimeType)) {
      return allowedMimeTypes[mimeType];
    }
    return null;
  }
}
