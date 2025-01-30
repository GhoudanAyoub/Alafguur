import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../service/model/photo_viewer_model.dart';
import '../style/common_widget_style.dart';
import 'image_loader_widget.dart';

typedef OnFlagCallback = void Function(int index);
typedef OnChangeFlagCallback = void Function(int index);

mixin PreviewPhotoWidgetMixin {
  void showPhotoList(
    BuildContext context,
    List<PhotoViewerModel>? photos, {
    int startIndex = 0,
    OnFlagCallback? onFlagCallback,
    OnChangeFlagCallback? onChangeCallback,
  }) {
    final pageController = PageController(initialPage: startIndex);

    showPlatformDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => scaffoldContainer(
        context,
        body: previewPhotosPageContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: onFlagCallback == null
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (onFlagCallback != null)
                    previewPhotosFlagPhotoContainer(
                      () => onFlagCallback(
                        pageController.page!.toInt(),
                      ),
                    ),
                  previewPhotosClosePageContainer(
                    () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  allowImplicitScrolling: true,
                  controller: pageController,
                  onPageChanged: onChangeCallback != null
                      ? (int index) => onChangeCallback(index)
                      : null,
                  children: photos!
                      .map(
                        (photo) => Center(
                          child: photo.url != null
                              ? _getImageViewer(photo.url)
                              : _getBytesImageViewer(photo.bytes!),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageViewer(String? url) {
    return ImageLoaderWidget(
      imageUrl: url,
      width: null,
      height: null,
    );
  }

  Widget _getBytesImageViewer(Uint8List bytes) {
    return Image.memory(
      bytes,
      width: null,
      height: null,
      fit: BoxFit.cover,
      repeat: ImageRepeat.noRepeat,
    );
  }
}
