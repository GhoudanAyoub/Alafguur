import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/error/verify_email_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/error/verify_email_widget_style.dart';
import '../../style/form/form_builder_widget_style.dart';
import '../flushbar_widget_mixin.dart';
import '../form/form_builder_widget.dart';
import '../loading_indicator_widget.dart';
import '../navigation_widget_mixin.dart';

final serviceLocator = GetIt.instance;

class ChangeEmailWidget extends StatefulWidget
    with NavigationWidgetMixin, FlushbarWidgetMixin {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailWidget>
    with FlushbarWidgetMixin, NavigationWidgetMixin {
  late final VerifyEmailState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<VerifyEmailState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _formBuilderWidget.registerFormElements(
      _state.getChangeEmailFormElements(),
    );

    // apply a custom form renderer
    _formBuilderWidget.registerFormRenderer(
      blankPagesFormRenderer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          disableContent: _state.isRequestPending,
          backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
          body: blankBasedPageContainer(
            context,
            <Widget>[
              // an icon
              blankBasedPageImageContainer(
                SkMobileFont.ic_success,
                118,
                colorIcon: AppSettingsService.themeCommonSuccessIconColor,
                paddingTop: 40,
              ),
              // a registration successful label
              blankBasedPageTitleContainer(
                LocalizationService.of(context).t(
                  'verify_email_registration_successful',
                ),
              ),
              // a registration successful desc
              blankBasedPageDescrContainer(
                LocalizationService.of(context).t(
                  'verify_email_check_email_page_desc',
                ),
              ),
              // a form container
              verifyEmailWidgetFormContainer(
                Column(
                  children: [
                    // a form
                    verifyEmailWidgetFormInputContainer(
                      _formBuilderWidget,
                    ),
                    // a loading bar
                    if (_state.isRequestPending) LoadingIndicatorWidget(),
                    // a send email button
                    if (!_state.isRequestPending)
                      verifyEmailWidgetButtonContainer(
                        context,
                        'verify_email_resend_button',
                        _changeAndVerifyEmail,
                      )
                  ],
                ),
              )
            ].toColumn(),
            backToStarterCallback: () =>
                redirectToMainPage(context, cleanAuthCredentials: true),
          ),
        );
      },
    );
  }

  /// Update user profile with new email and verify it.
  void _changeAndVerifyEmail() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      showMessage('form_general_error', context);

      return;
    }

    final formValues = _formBuilderWidget.getFormValues();
    final result = await _state.changeEmail(formValues['email']);

    if (!result.success) {
      showMessage('error_occurred', context);

      return;
    }

    Navigator.pop(context);

    showMessage(
      'verify_email_mail_sent',
      context,
      searchParams: [
        'email',
      ],
      replaceParams: [
        formValues['email'],
      ],
    );
  }
}
