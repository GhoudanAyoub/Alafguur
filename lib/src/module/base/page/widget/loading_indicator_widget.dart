import 'package:flutter/material.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  const LoadingIndicatorWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      child: const LinearProgressIndicator(),
      duration: const Duration(milliseconds: 300),
      opacity: 1,
    );
  }
}
