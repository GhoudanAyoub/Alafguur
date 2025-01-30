import '../../../../../app/service/app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../../base/page/widget/form/form_builder_widget.dart';
import '../../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../../../../base/service/localization_service.dart';
import '../../state/dashboard_search_state.dart';

final serviceLocator = GetIt.instance;

class DashboardSearchFilterPopupWidget extends StatefulWidget
    with FlushbarWidgetMixin {
  const DashboardSearchFilterPopupWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardSearchFilterPopupState createState() =>
      _DashboardSearchFilterPopupState();
}

class _DashboardSearchFilterPopupState
    extends State<DashboardSearchFilterPopupWidget> {
  late final DashboardSearchState _state;
  late final FormBuilderWidget _formBuilderWidget;

  static const _SKELETON_BARS_COUNT = 4;

  @override
  void initState() {
    super.initState();
    _state = serviceLocator.get<DashboardSearchState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _formBuilderWidget.registerFormOnChangedCallback(_onChangedValueCallback);
    _state.initializeFilters(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        scrollable: true,
        header: LocalizationService.of(context).t('search_filter_page_header'),
        body: _state.isFiltersLoading
            ? ListSkeletonWidget(
                barsCount: _SKELETON_BARS_COUNT,
              )
            : _filters(),
        headerActions: [
          if (!_state.isFiltersLoading)
            appBarTextButtonContainer(
              _done,
              LocalizationService.of(context).t('done'),
            )
        ],
        backgroundColor: _state.isFiltersLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  /// return a list of user search filters
  Widget _filters() {
    return formBasedPageContainer(
      Column(
        children: [
          formBasedPageFormContainer(_formBuilderWidget),
        ],
      ),
    );
  }

  _done() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    Navigator.pop(context);
    _state.searchByFilters(_formBuilderWidget.getFormElementsList());
  }

  OnChangedValueCallback? _onChangedValueCallback(
    String key,
    dynamic value,
  ) {
    // reload the form elements according to a new `gender`
    if (key == 'match_sex') {
      final List gender = value;

      if (gender.isNotEmpty) {
        _state.reloadFilters(_formBuilderWidget, gender[0]);
      }
    }

    return null;
  }
}
