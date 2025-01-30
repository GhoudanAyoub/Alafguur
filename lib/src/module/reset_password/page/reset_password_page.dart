import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import 'state/reset_password_state.dart';

final serviceLocator = GetIt.instance;

class ResetPasswordPage extends AbstractPage {
  ResetPasswordPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final ResetPasswordState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<ResetPasswordState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _formBuilderWidget.registerFormElements(
      _state.getResetPasswordFormElements(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          showHeaderBackButton: !_state.isRequestPending,
          header: LocalizationService.of(context).t(
            'forgot_password_new_password_page_title',
          ),
          headerActions: [
            !_state.isRequestPending
                ? appBarTextButtonContainer(
                    _resetPassword,
                    LocalizationService.of(context).t('next'),
                  )
                : scaffoldHeaderActionLoading(),
          ],
          body: formBasedPageContainer(
            Column(
              children: [
                formBasedPageDescContainer(
                  LocalizationService.of(context).t(
                    'forgot_password_new_password_desc',
                  ),
                ),

                // new password inputs
                formBasedPageFormContainer(_formBuilderWidget),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetPassword() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    final result = await _state.assignNewPassword(
      widget.widgetParams!['code'],
      _formBuilderWidget['password']!.value,
    );

    if (!result.success) {
      widget.showAlert(
        context,
        result.message!,
        title: LocalizationService.of(context).t('error_occurred'),
        translate: false,
      );

      return;
    }

    widget.redirectToMainPage(context);
    widget.showMessage(
      'forgot_password_reset_successful',
      context,
    );
  }
}
