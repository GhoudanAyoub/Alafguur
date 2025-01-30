import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/root_state.dart';
import '../../style/common_widget_style.dart';
import '../navigation_widget_mixin.dart';

final serviceLocator = GetIt.instance;

class NotFoundWidget extends StatelessWidget with NavigationWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      showHeaderBackButton: false,
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
      body: blankBasedPageContainer(
        context,
        blankBasedPageContentWrapperContainer(
          <Widget>[
            // an icon
            blankBasedPageImageContainer(
              SkMobileFont.ic_not_found,
              75,
            ),
            // a not found title
            blankBasedPageTitleContainer(
              LocalizationService.of(context).t(
                'not_found',
              ),
            ),
            // a button
            if (serviceLocator.get<RootState>().isApplicationLoaded)
              blankBasedPageButtonContainer(
                context,
                () => redirectToMainPage(
                  context,
                  cleanAppErrors: true,
                ),
                LocalizationService.of(context).t('ok'),
                paddingTop: 34,
              )
          ].toColumn(),
        ),
      ),
    );
  }
}
