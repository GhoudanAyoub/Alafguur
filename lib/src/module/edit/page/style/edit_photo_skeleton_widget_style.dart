import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

final editPhotoSkeletonWidgetBodyContainer = (Widget skeleton) =>
    Styled.widget(child: skeleton).padding(horizontal: 16, top: 16);
