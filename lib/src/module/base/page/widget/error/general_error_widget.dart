import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../style/common_widget_style.dart';
import '../navigation_widget_mixin.dart';

class GeneralErrorWidget extends StatelessWidget with NavigationWidgetMixin {
  final bool isAppLoaded;

  const GeneralErrorWidget({
    Key? key,
    this.isAppLoaded = false,
  }) : super(key: key);

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
              SkMobileFont.ic_app_error,
              187,
            ),
            if (isAppLoaded) ...[
              // an error title
              blankBasedPageTitleContainer(
                  LocalizationService.of(context).t('app_error_page_header')),
              //an error description
              blankBasedPageDescrContainer(
                LocalizationService.of(context).t('app_error_page_description'),
              ),
              // a button
              blankBasedPageButtonContainer(
                context,
                () => redirectToMainPage(
                  context,
                  cleanAppErrors: true,
                ),
                LocalizationService.of(context).t('ok'),
              ),
            ]
          ].toColumn(),
        ),
      ),
    );
  }
}
