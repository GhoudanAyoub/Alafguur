import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../../base/page/style/common_widget_style.dart';
import '../../../../base/page/widget/flushbar_widget_mixin.dart';
import '../../../../base/page/widget/form/form_builder_widget.dart';
import '../../../../base/page/widget/modal_widget_mixin.dart';
import '../../../../base/page/widget/skeleton/list_skeleton_widget.dart';
import '../../../../base/service/localization_service.dart';
import '../../state/dashboard_tinder_state.dart';

final serviceLocator = GetIt.instance;

class DashboardTinderFilterPopupWidget extends StatefulWidget
    with FlushbarWidgetMixin, ModalWidgetMixin {
  const DashboardTinderFilterPopupWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardTinderFilterPopupState createState() =>
      _DashboardTinderFilterPopupState();
}

class _DashboardTinderFilterPopupState
    extends State<DashboardTinderFilterPopupWidget> {
  late final DashboardTinderState _state;
  late final FormBuilderWidget _formBuilderWidget;

  int _skeletonBarsCount = 4;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<DashboardTinderState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.initializeFilters(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        scrollable: true,
        header: LocalizationService.of(context).t('tinder_filter_page_header'),
        body: _state.isFiltersLoading
            ? ListSkeletonWidget(
                barsCount: _skeletonBarsCount,
              )
            : _filters(),
        headerActions: [
          if (!_state.isFiltersLoading) ...[
            if (_state.isFilterSetup)
              appBarTextButtonContainer(
                _clear,
                LocalizationService.of(context).t('clear'),
              ),
            appBarTextButtonContainer(
              _done,
              LocalizationService.of(context).t('done'),
            ),
          ]
        ],
        backgroundColor: _state.isFiltersLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  /// return a list of search filters
  Widget _filters() {
    return formBasedPageContainer(
      Column(
        children: [
          formBasedPageFormContainer(_formBuilderWidget),
        ],
      ),
    );
  }

  void _clear() {
    widget.showConfirmation(
      context,
      'tinder_filter_clear_confirmation',
      () {
        _state.clearFilter();
        Navigator.pop(context);
        widget.showMessage('tinder_filter_cleared', context);
      },
    );
  }

  void _done() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    Navigator.pop(context);

    _state.saveFilter(_formBuilderWidget.getFormElementsList());
  }
}
