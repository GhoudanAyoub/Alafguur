import 'package:flutter/widgets.dart';

Widget imageLoaderPreviewContainer(
  double? width,
  double? height,
  Widget child,
) =>
    Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: child,
    );
