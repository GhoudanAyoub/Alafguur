import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/error/verify_email_state.dart';
import '../../state/root_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/error/verify_email_widget_style.dart';
import '../../style/form/form_builder_widget_style.dart';
import '../deep_link_widget_mixin.dart';
import '../flushbar_widget_mixin.dart';
import '../form/form_builder_widget.dart';
import '../loading_indicator_widget.dart';
import '../navigation_widget_mixin.dart';
import 'change_email_widget.dart';

final serviceLocator = GetIt.instance;

class VerifyEmailWidget extends StatefulWidget
    with DeepLinkWidgetMixin, NavigationWidgetMixin, FlushbarWidgetMixin {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailWidget>
    with FlushbarWidgetMixin, NavigationWidgetMixin {
  late final FormBuilderWidget _formBuilderWidget;
  late final VerifyEmailState _state;

  @override
  void initState() {
    super.initState();

    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state = serviceLocator.get<VerifyEmailState>();

    _formBuilderWidget.registerFormElements(
      _state.getCodeVerificationFormElements(null),
    );

    // apply a custom form renderer
    _formBuilderWidget.registerFormRenderer(
      blankPagesFormRenderer(),
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
          disableContent: _state.isRequestPending,
          backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
          scrollable: true,
          body: verifyEmailWidgetWrapperContainer(
            context,
            blankBasedPageContainer(
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
                    'verify_email_check_code_page_desc',
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
                      // a verify code button
                      verifyEmailWidgetButtonContainer(
                        context,
                        'verify_email_done_button',
                        _verifyCode,
                      )
                    ],
                  ),
                ),
                // a resend verification email button
                verifyEmailWidgetTextButtonContainer(
                  context,
                  _openChangeEmailPopup,
                ),
              ].toColumn(),
              backToStarterCallback: () =>
                  redirectToMainPage(context, cleanAuthCredentials: true),
            ),
          ),
        );
      },
    );
  }

  OnDeepLinkCallback _onDeepLink() {
    return (String? link) {
      if (link == null) {
        return;
      }

      final verifyCode = widget.getEmailVerifyCode(link);

      if (verifyCode == null) {
        return;
      }

      // fill the form using the received verify code
      _formBuilderWidget.unregisterAllFormElements();
      _formBuilderWidget.registerFormElements(
        _state.getCodeVerificationFormElements(verifyCode),
      );

      widget.clearDeepLink();
    };
  }

  /// verify email validation code
  void _verifyCode() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      showMessage('form_general_error', context);

      return;
    }

    final formValues = _formBuilderWidget.getFormValues();
    final verificationResult = await _state.verifyCode(formValues['code']);

    if (!verificationResult.valid) {
      showMessage('verify_email_invalid_code', context);

      return;
    }

    widget.redirectToMainPage(context);
    showMessage('verify_email_verification_successful', context);
  }

  /// open change email popup
  void _openChangeEmailPopup() {
    _formBuilderWidget.reset();

    showPlatformDialog(
      context: context,
      builder: (_) => ChangeEmailWidget(),
    );
  }
}
