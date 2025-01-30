import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../app/service/app_settings_service.dart';
import '../page/style/common_widget_style.dart';
import '../service/localization_service.dart';

class AccessDeniedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
      header: LocalizationService.of(context).t('permission_denied_header'),
      body: blankBasedPageContainer(
        context,
        blankBasedPageContentWrapperContainer(
          <Widget>[
            // an icon
            blankBasedPageImageContainer(
              SkMobileFont.ic_no_permission,
              75,
              colorIcon: AppSettingsService.themeCommonDangerousColor,
            ),
          ].toColumn(),
        ),
      ),
    );
  }
}
