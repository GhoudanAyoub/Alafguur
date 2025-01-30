import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../service/localization_service.dart';
import '../style/common_widget_style.dart';
import 'flag_content_widget.dart';

final flagContentStateKey = GlobalKey<FlagContentWidgetState>();

mixin FlagContentWidgetMixin {
  void showFlagContent(
    BuildContext context,
    int identityId,
    String entityType, {
    Function? onFlaggedCallback,
  }) {
    showPlatformDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t('flag_page_header'),
        headerActions: [
          appBarTextButtonContainer(
            () => flagContentStateKey.currentState!.flagContent(
              identityId,
              entityType,
              onFlaggedCallback: onFlaggedCallback,
            ),
            LocalizationService.of(context).t('done'),
          ),
        ],
        body: FlagContentWidget(
          key: flagContentStateKey,
        ),
      ),
    );
  }
}
