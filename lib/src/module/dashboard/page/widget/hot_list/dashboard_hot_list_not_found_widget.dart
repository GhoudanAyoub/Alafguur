import 'package:flutter/material.dart';

import '../../../../base/service/localization_service.dart';
import '../../style/hot_list/dashboard_hot_list_not_found_widget_style.dart';

class DashboardHotListNotFoundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // an icon
        dashboardHotListWidgetEmptyIconContainer(),
        // a title
        dashboardHotListWidgetEmptyTextContainer(
          LocalizationService.of(context).t('hot_list_empty_desc'),
        ),
      ],
    );
  }
}
