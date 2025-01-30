import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../service/localization_service.dart';

typedef OnConfirmCallback = void Function();
typedef OnCancelCallback = void Function();

mixin ModalWidgetMixin {
  void showAlert(
    BuildContext context,
    String message, {
    String? title,
    bool translate = true,
    Function? onDismissCallback,
  }) {
    _showModalWindow(
      context,
      message,
      [
        ElevatedButton(
          child: Text(
            LocalizationService.of(context).t('ok'),
          ),
          onPressed: () {
            Navigator.pop(context);

            if (onDismissCallback != null) {
              onDismissCallback();
            }
          },
        ),
      ],
      title: title,
      translate: translate,
    );
  }

  void showConfirmation(
    BuildContext context,
    String message,
    OnConfirmCallback confirmCallback, {
    String? title,
    bool translate = true,
    String yesLabel = 'yes',
    String noLabel = 'nope',
    OnCancelCallback? cancelCallback,
    bool dismissible = true,
  }) {
    _showModalWindow(
      context,
      message,
      [
        PlatformTextButton(
          child: Text(
            LocalizationService.of(context).t(noLabel),
          ),
          onPressed: () {
            Navigator.pop(context);
            cancelCallback?.call();
          },
        ),
        PlatformTextButton(
          child: Text(
            LocalizationService.of(context).t(yesLabel),
          ),
          onPressed: () {
            Navigator.pop(context);
            confirmCallback();
          },
        ),
      ],
      title: title,
      translate: translate,
      dismissible: dismissible,
    );
  }

  void _showModalWindow(
    BuildContext context,
    String message,
    List<Widget> actions, {
    String? title,
    bool translate = true,
    bool dismissible = true,
  }) {
    String? actualTitle;

    if (title != null) {
      actualTitle =
          translate ? LocalizationService.of(context).t(title) : title;
    }

    final actualMessage =
        translate ? LocalizationService.of(context).t(message) : message;

    showPlatformDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) => PlatformAlertDialog(
        title: actualTitle != null ? Text(actualTitle) : null,
        content: Text(actualMessage),
        actions: actions,
      ),
    );
  }
}
