import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../style/common_widget_style.dart';

class MaintenanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
      body: blankBasedPageContainer(
        context,
        blankBasedPageContentWrapperContainer(
          <Widget>[
            // an icon
            blankBasedPageImageContainer(
              SkMobileFont.ic_maintenance,
              194,
            ),
            // a maintenance title
            blankBasedPageTitleContainer(
              LocalizationService.of(context).t(
                'maintenance_mode_error',
              ),
            ),
            // a maintenance desc
            blankBasedPageDescrContainer(
              LocalizationService.of(context).t(
                'maintenance_mode',
              ),
            ),
          ].toColumn(),
        ),
      ),
    );
  }
}
