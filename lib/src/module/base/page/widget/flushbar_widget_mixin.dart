import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../service/localization_service.dart';
import '../state/root_state.dart';

mixin FlushbarWidgetMixin {
  showMessage(
    String message,
    BuildContext context, {
    bool translate = true,
    List<String> searchParams = const [],
    List<String> replaceParams = const [],
    int duration = 0,
    int animationDuration = 500,
  }) {
    final actualMessage = translate
        ? LocalizationService.of(context).t(
            message,
            searchParams: searchParams,
            replaceParams: replaceParams,
          )
        : message;

    if (duration == 0) {
      duration = GetIt.instance<RootState>().getSiteSetting(
        'toastDuration',
        3000,
      );
    }

    Flushbar? flush;

    flush = Flushbar(
      message: actualMessage,
      isDismissible: false,
      backgroundColor: AppSettingsService.themeCommonToasterBackgroundColor,
      mainButton: TextButton(
        child: Text(
          LocalizationService.of(context).t('ok'),
          style: TextStyle(
            color: AppSettingsService.themeCommonToasterTextColor,
          ),
        ),
        onPressed: () {
          flush?.dismiss();
        },
      ),
      duration: Duration(milliseconds: duration),
      animationDuration: Duration(
        milliseconds: animationDuration,
      ),
    )..show(context);
  }
}
