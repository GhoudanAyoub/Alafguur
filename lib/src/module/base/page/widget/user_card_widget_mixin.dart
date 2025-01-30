import 'package:flutter/material.dart';

import '../style/common_widget_style.dart';

mixin UserCardWidgetMixin {
  /// get the count of cards per row
  int getCardsCountPerRow(BuildContext context) {
    return (MediaQuery.of(context).size.width / defaultUserCardWidth).floor();
  }
}
