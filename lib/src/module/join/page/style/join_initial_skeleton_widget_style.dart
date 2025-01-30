import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

final joinInitialSkeletonContainer = (
  Widget child,
) =>
    Styled.widget(
      child: child,
    ).alignment(Alignment.center).padding(top: 16);

final joinInitialAvatarSkeletonContainer = (
  Widget child,
) =>
    Styled.widget(child: child).padding(top: 16);
