import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../../base/service/localization_service.dart';
import '../../state/dashboard_tinder_state.dart';
import '../../style/tinder/dashboard_tinder_location_issue_widget_style.dart';

class DashboardTinderLocationIssueWidget extends StatelessWidget
    with FlushbarWidgetMixin {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) => blankBasedPageContainer(
        context,
        blankBasedPageContentWrapperContainer(
          Column(
            children: [
              // an icon
              blankBasedPageImageContainer(
                SkMobileFont.ic_location,
                141,
              ),

              // a title
              blankBasedPageTitleContainer(
                LocalizationService.of(context).t('location_issue_title'),
              ),
              // a desc
              blankBasedPageDescrContainer(
                LocalizationService.of(context).t('location_issue_desc'),
              ),
              // a location checker  button
              dashboardTinderLocationIssueWidgetButtonContainer(
                LocalizationService.of(context).t('check_location'),
                () => _checkLocation(context),
                _state.isLocationLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLocation(BuildContext context) async {
    final position = await _state.checkLocation();

    if (position == null) {
      showMessage('location_error_desc', context);
    }
  }

  DashboardTinderState get _state => GetIt.instance.get<DashboardTinderState>();
}
