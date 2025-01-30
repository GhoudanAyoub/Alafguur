import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/error/complete_profile_state.dart';
import '../../style/common_widget_style.dart';
import '../flushbar_widget_mixin.dart';
import '../form/form_builder_widget.dart';
import '../navigation_widget_mixin.dart';
import '../skeleton/list_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class CompleteProfileWidget extends StatefulWidget
    with FlushbarWidgetMixin, NavigationWidgetMixin {
  const CompleteProfileWidget({
    Key? key,
  }) : super(key: key);

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfileWidget> {
  late final CompleteProfileState _state;
  late final FormBuilderWidget _formBuilderWidget;

  static const _SKELETON_BARS_COUNT = 4;

  @override
  void initState() {
    super.initState();
    _state = serviceLocator.get<CompleteProfileState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state.init(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        header:
            LocalizationService.of(context).t('complete_profile_page_header'),
        headerActions: !_state.isPageLoading
            ? [
                !_state.isUserUpdating
                    ? appBarTextButtonContainer(
                        () => _finalize(context),
                        LocalizationService.of(context).t('done'),
                      )
                    : scaffoldHeaderActionLoading(),
              ]
            : null,
        body: _state.isPageLoading
            ? ListSkeletonWidget(
                barsCount: _SKELETON_BARS_COUNT,
              )
            : _completeProfilePage(),
        scrollable: true,
        showHeaderBackButton: false,
        disableContent: _state.isUserUpdating,
        backgroundColor: _state.isPageLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  Widget _completeProfilePage() {
    return formBasedPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // description
          formBasedPageDescContainer(
            LocalizationService.of(context).t('complete_account_desc'),
          ),
          // complete profile form elements
          formBasedPageFormContainer(_formBuilderWidget),
        ],
      ),
    );
  }

  _finalize(BuildContext context) async {
    if (!await _formBuilderWidget.isFormValid()) {
      widget.showMessage('form_general_error', context);

      return;
    }

    await _state.updateUser(
      _formBuilderWidget.getFormElementsList(),
    );

    // redirect to the dashboard
    widget.redirectToMainPage(context);
  }
}
