import 'package:flutter/cupertino.dart';

class LoadingSpinnerWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const LoadingSpinnerWidget({
    Key? key,
    this.width,
    this.height,
    this.radius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (width == null && height == null) {
      return CupertinoActivityIndicator(radius: radius);
    }
    return Container(
      width: width != null ? width : null,
      height: height != null ? height : MediaQuery.of(context).size.height / 3,
      child: Center(
        child: CupertinoActivityIndicator(radius: radius),
      ),
    );
  }
}
