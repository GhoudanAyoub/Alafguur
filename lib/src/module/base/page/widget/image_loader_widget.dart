import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../style/image_loader_widget_style.dart';
import 'loading_spinner_widget.dart';

class ImageLoaderWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final String fallbackImage;
  final BoxFit fit;
  final ImageRepeat repeat;
  final bool showPlaceholder;

  /// Creates an [ImageLoaderWidget] instance.
  ///
  /// [onLoadedCallback] callback function is triggered once the image is loaded.
  ImageLoaderWidget({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fallbackImage = 'assets/image/common/ic_no_image.png',
    this.fit = BoxFit.cover,
    this.repeat = ImageRepeat.noRepeat,
    this.showPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      placeholder: showPlaceholder ? (context, url) => _loading() : null,
      errorWidget: (context, url, error) => _getFallbackImage(),
    );
  }

  Widget _getFallbackImage() {
    return imageLoaderPreviewContainer(
      width,
      height,
      Image.asset(
        fallbackImage,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  Widget _loading() {
    return imageLoaderPreviewContainer(
      width,
      height,
      LoadingSpinnerWidget(),
    );
  }
}
