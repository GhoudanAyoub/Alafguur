import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service/localization_service.dart';
import 'modal_widget_mixin.dart';

mixin UrlLauncherWidgetMixin on ModalWidgetMixin {
  launchUrl(
    BuildContext context,
    String url,
  ) async {
    if (await canLaunch(url) == true) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );

      return;
    }

    showAlert(
      context,
      LocalizationService.of(context).t('error_launching_url', searchParams: [
        'url',
      ], replaceParams: [
        url,
      ]),
      translate: false,
    );
  }
}
