import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import 'state/change_password_state.dart';

final serviceLocator = GetIt.instance;

class ChangePasswordPage extends AbstractPage {
  ChangePasswordPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final ChangePasswordState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<ChangePasswordState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state.initializeForm(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          showHeaderBackButton: !_state.isPasswordEditing,
          header:
              LocalizationService.of(context).t('change_password_page_title'),
          headerActions: !_state.isPasswordEditing
              ? [
                  !_state.isPasswordEditing
                      ? appBarTextButtonContainer(
                          _change,
                          LocalizationService.of(context).t('change'),
                        )
                      : scaffoldHeaderActionLoading(),
                ]
              : null,
          body: _changePasswordPage(),
          scrollable: true,
          disableContent: _state.isPasswordEditing,
        );
      },
    );
  }

  Widget _changePasswordPage() {
    return Column(
      children: [
        formBasedPageContainer(
          formBasedPageFormContainer(
            _formBuilderWidget,
          ),
        ),
      ],
    );
  }

  Future<void> _change() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    await _state.changePassword(
      _formBuilderWidget['oldPassword']!.value,
      _formBuilderWidget['password']!.value,
      _formBuilderWidget['repeatPassword']!.value,
    );

    Navigator.pop(context);
    widget.showMessage('password_changed', context);
  }
}
