import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../service/localization_service.dart';
import '../../service/model/action_sheet_model.dart';

mixin ActionSheetWidgetMixin {
  void showActionSheet(
    BuildContext context,
    List<ActionSheetModel> actions, {
    bool translate = true,
    bool addCancelAction = true,
    String? title,
    bool translateTitle = false,
  }) {
    // translate the title
    if (title != null && translateTitle) {
      title = LocalizationService.of(context).t(title);
    }

    // generate action widgets
    final List<Widget> actionsWidgets = actions.map((action) {
      final label = translate
          ? LocalizationService.of(context).t(action.label)
          : action.label;

      return PlatformWidget(
        cupertino: (_, __) => CupertinoActionSheetAction(
          child: Text(label),
          onPressed: () {
            Navigator.pop(context);
            action.callback();
          },
        ),
        material: (_, __) => ListTile(
          title: Text(label),
          onTap: () {
            Navigator.pop(context);
            action.callback();
          },
        ),
      );
    }).toList();

    showPlatformModalSheet(
      context: context,
      builder: (_) => PlatformWidget(
        cupertino: (_, __) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: actionsWidgets,
          cancelButton: addCancelAction
              ? CupertinoActionSheetAction(
                  child: Text(LocalizationService.of(context).t('Cancel')),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : null,
        ),
        material: (_, __) => Container(
          child: Wrap(
            children: [
              // a title
              if (title != null)
                ListTile(
                  subtitle: Text(title),
                ),
              // buttons
              ...!addCancelAction
                  ? actionsWidgets
                  : [
                      ...actionsWidgets,
                      ListTile(
                        title:
                            Text(LocalizationService.of(context).t('Cancel')),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
            ],
          ),
        ),
      ),
    );
  }
}
