import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

final profileSkeletonWidgetButtonContainer = (Widget child) => SizedBox(
      child: child,
      height: 52,
      width: 52,
    ).padding(horizontal: 8);

final profileSkeletonWidgetButtonsWrapperContainer =
    (Widget child) => Styled.widget(child: child).padding(all: 16);
