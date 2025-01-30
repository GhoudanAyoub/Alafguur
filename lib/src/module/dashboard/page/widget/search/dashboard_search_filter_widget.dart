import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/search_field_widget.dart';
import '../../../../base/service/localization_service.dart';
import '../../state/dashboard_search_state.dart';
import '../../style/search/dashboard_search_widget_style.dart';
import 'dashboard_search_filter_popup_widget.dart';

final searchFieldStateKey = GlobalKey<SearchFieldWidgetState>();

class DashboardSearchFilterWidget extends StatefulWidget {
  const DashboardSearchFilterWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardSearchFilterState createState() => _DashboardSearchFilterState();
}

class _DashboardSearchFilterState extends State<DashboardSearchFilterWidget> {
  late final DashboardSearchState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<DashboardSearchState>();
    _state.setUserNameFilterChangeCallback(
      _onUserNameFilterChangeCallback(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return dashboardSearchBarWrapperContainer(
      Row(
        mainAxisAlignment: _state.isSearchByUserNameAllowed
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          // a search field
          if (_state.isSearchByUserNameAllowed)
            Expanded(
              child: dashboardSearchBarContainer(
                SearchFieldWidget(
                  key: searchFieldStateKey,
                  onChangedValueCallback: _onChangedSearchValueCallback(),
                  value: _state.userNameFilter,
                  placeholder: 'username_input',
                  iconsColor:
                      AppSettingsService.themeCommonSearchFieldIconsColor,
                  backgroundColor:
                      AppSettingsService.themeCommonSearchFieldBackgroundColor,
                  placeholderColor:
                      AppSettingsService.themeCommonFormPlaceholderColor,
                  textColor: AppSettingsService.themeCommonTextColor,
                ),
              ),
            ),
          // a search icon
          dashboardSearchFilterIconContainer(
            () => _showFiltersPopup(context),
            isRtlMode(context),
            _state.isSearchByUserNameAllowed,
          ),
          // a search filter label
          if (!_state.isSearchByUserNameAllowed)
            dashboardSearchLabelContainer(
              LocalizationService.of(context).t('search_filter'),
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

  /// the search field callback handler
  OnChangedSearchValueCallback _onChangedSearchValueCallback() {
    return (String value) {
      _state.searchByUserName(value);
    };
  }

  OnUserNameFilterChangeCallback _onUserNameFilterChangeCallback() {
    return (String? userName) {
      if (userName != searchFieldStateKey.currentState!.getValue()) {
        searchFieldStateKey.currentState!.setValue(
          userName!,
        );
      }
    };
  }
}
