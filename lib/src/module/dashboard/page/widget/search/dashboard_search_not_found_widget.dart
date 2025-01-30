import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/service/localization_service.dart';
import 'dashboard_search_filter_popup_widget.dart';

class DashboardSearchNotFoundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // an icon
          blankBasedPageImageContainer(
            SkMobileFont.ic_not_found,
            75,
          ),
          // a title
          blankBasedPageTitleContainer(
            LocalizationService.of(context).t('empty_user_search_header'),
          ),
          // a search button
          blankBasedPageTextButtonContainer(
            () => _showFiltersPopup(context),
            LocalizationService.of(context).t('empty_user_search_desc'),
          ),
        ],
      ),
    );
  }

  void _showFiltersPopup(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => DashboardSearchFilterPopupWidget(),
    );
  }
}
