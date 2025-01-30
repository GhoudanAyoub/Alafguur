import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import '../reset_password_config.dart';
import 'state/reset_password_state.dart';

final serviceLocator = GetIt.instance;

class EmailVerificationPage extends AbstractPage {
  EmailVerificationPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late final FormBuilderWidget _formBuilderWidget;
  late final ResetPasswordState _state;

  @override
  void initState() {
    super.initState();

    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state = serviceLocator.get<ResetPasswordState>();

    _formBuilderWidget.registerFormElements(
      _state.getCheckEmailFormElements(),
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
            'forgot_password_check_email_page_title',
          ),
          headerActions: [
            !_state.isRequestPending
                ? appBarTextButtonContainer(
                    _sendEmailVerificationMessage,
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
                    'forgot_password_email_check_desc',
                  ),
                ),

                // email input
                formBasedPageFormContainer(_formBuilderWidget),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendEmailVerificationMessage() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    final result = await _state.sendVerificationMessage(
      _formBuilderWidget['email']!.value,
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

    Navigator.pushNamed(
      context,
      widget.processUrlArguments(RESET_PASSWORD_VERIFY_URL, [
        'code',
      ], [
        '',
      ]),
    );
  }
}
