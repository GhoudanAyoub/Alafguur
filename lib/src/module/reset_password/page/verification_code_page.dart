import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/state/root_state.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import '../reset_password_config.dart';
import 'state/reset_password_state.dart';

final serviceLocator = GetIt.instance;

class VerificationCodePage extends AbstractPage {
  VerificationCodePage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late final ResetPasswordState _state;
  late final FormBuilderWidget _formBuilderWidget;
  late final String? code;

  @override
  void initState() {
    super.initState();

    code = widget.routeParams!['code'][0] ?? null;

    _state = serviceLocator.get<ResetPasswordState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _formBuilderWidget.registerFormElements(
      _state.getVerificationCodeFormElements(code),
    );

    _state.setDeeplinkCallback(_onDeepLink());

    _state.init();
  }

  @override
  void dispose() {
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          showHeaderBackButton: !_state.isRequestPending,
          header: LocalizationService.of(context).t(
            'forgot_password_check_code_page_title',
          ),
          headerActions: [
            !_state.isRequestPending
                ? appBarTextButtonContainer(
                    _verifyCode,
                    LocalizationService.of(context).t('next'),
                  )
                : scaffoldHeaderActionLoading(),
          ],
          disableContent: _state.isRequestPending,
          body: formBasedPageContainer(
            Column(
              children: [
                formBasedPageDescContainer(
                  LocalizationService.of(context).t(
                    'forgot_password_code_check_desc',
                  ),
                ),

                // code input
                formBasedPageFormContainer(_formBuilderWidget),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyCode() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    final result = await _state.validateEmailVerificationCode(
      _formBuilderWidget['code']!.value,
    );

    if (!result.valid) {
      widget.showAlert(
        context,
        'forgot_password_code_invalid',
        title: 'error_occurred',
      );

      return;
    }

    Navigator.pushNamed(
      context,
      RESET_PASSWORD_NEW_PASSWORD_URL,
      arguments: {
        'code': _formBuilderWidget['code']!.value,
      },
    );
  }

  OnDeepLinkCallback _onDeepLink() {
    return (String? link) {
      if (link == null) {
        return;
      }

      final resetCode = widget.getResetPasswordCode(link);

      if (resetCode == null) {
        return;
      }

      // fill the form using the received reset code
      _formBuilderWidget.unregisterAllFormElements();
      _formBuilderWidget.registerFormElements(
        _state.getVerificationCodeFormElements(resetCode),
      );

      widget.clearDeepLink();
    };
  }
}
