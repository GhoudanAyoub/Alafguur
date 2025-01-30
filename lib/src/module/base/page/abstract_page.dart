import 'package:flutter/material.dart';

import 'widget/action_sheet_widget_mixin.dart';
import 'widget/analytic_widget_mixin.dart';
import 'widget/deep_link_widget_mixin.dart';
import 'widget/flushbar_widget_mixin.dart';
import 'widget/keyboard_widget_mixin.dart';
import 'widget/modal_widget_mixin.dart';
import 'widget/navigation_widget_mixin.dart';
import 'widget/rtl_widget_mixin.dart';

abstract class AbstractPage extends StatefulWidget
    with
        KeyboardWidgetMixin,
        DeepLinkWidgetMixin,
        AnalyticWidgetMixin,
        RtlWidgetMixin,
        FlushbarWidgetMixin,
        NavigationWidgetMixin,
        ModalWidgetMixin,
        ActionSheetWidgetMixin {
  /// URL parameters.
  final Map<String, dynamic>? routeParams;

  /// Widget-specific parameters.
  final Map<String, dynamic>? widgetParams;

  const AbstractPage({
    Key? key,
    this.routeParams,
    this.widgetParams,
  }) : super(key: key);
}
