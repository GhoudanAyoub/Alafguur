import 'package:flutter/material.dart';

final profilePagePhotosContainer = (
  BuildContext context,
  Widget child,
) =>
    Container(
      child: child,
      height: MediaQuery.of(context).size.height / 2,
    );
