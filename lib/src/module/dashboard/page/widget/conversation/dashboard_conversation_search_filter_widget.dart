import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/widget/search_field_widget.dart';
import '../../state/dashboard_conversation_state.dart';
import '../../style/conversation/dashboard_conversation_widget_style.dart';

final serviceLocator = GetIt.instance;

class DashboardConversationSearchFilterWidget extends StatefulWidget {
  const DashboardConversationSearchFilterWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardConversationSearchFilterState createState() =>
      _DashboardConversationSearchFilterState();
}

class _DashboardConversationSearchFilterState
    extends State<DashboardConversationSearchFilterWidget> {
  late final DashboardConversationState _state;

  @override
  void initState() {
    super.initState();
    _state = serviceLocator.get<DashboardConversationState>();
  }

  @override
  Widget build(BuildContext context) {
    return dashboardConversationWidgetSearchBarContainer(
      SearchFieldWidget(
        onChangedValueCallback: _onChangedSearchValueCallback(),
        value: _state.userNameFilter,
        placeholder: 'username_input',
        delay: 0,
        iconsColor: AppSettingsService.themeCommonSearchFieldIconsColor,
        backgroundColor:
            AppSettingsService.themeCommonSearchFieldBackgroundColor,
        placeholderColor: AppSettingsService.themeCommonFormPlaceholderColor,
        textColor: AppSettingsService.themeCommonTextColor,
      ),
    );
  }

  /// the search field callback handler
  OnChangedSearchValueCallback _onChangedSearchValueCallback() {
    return (String value) {
      _state.userNameFilter = value != '' ? value : null;
    };
  }
}
