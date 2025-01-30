import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/error/verify_phone_code_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/error/verify_phone_widget_style.dart';
import '../../style/form/form_builder_widget_style.dart';
import '../flushbar_widget_mixin.dart';
import '../form/form_builder_widget.dart';
import '../keyboard_widget_mixin.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../navigation_widget_mixin.dart';
import 'verify_phone_number_widget.dart';

final serviceLocator = GetIt.instance;

class VerifyPhoneCodeWidget extends StatefulWidget
    with
        FlushbarWidgetMixin,
        NavigationWidgetMixin,
        ModalWidgetMixin,
        KeyboardWidgetMixin {
  @override
  _VerifyPhoneCodePageState createState() => _VerifyPhoneCodePageState();
}

class _VerifyPhoneCodePageState extends State<VerifyPhoneCodeWidget> {
  late final FormBuilderWidget _formBuilderWidget;
  late final VerifyPhoneCodeState _state;

  @override
  void initState() {
    super.initState();

    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state = serviceLocator.get<VerifyPhoneCodeState>();

    // apply a custom form renderer
    _formBuilderWidget.registerFormRenderer(
      blankPagesFormRenderer(),
    );

    _state.init(_formBuilderWidget);
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
          body: verifyPhoneWidgetWrapperContainer(
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
                    'verify_phone_registration_successful',
                  ),
                ),
                // a registration successful desc
                blankBasedPageDescrContainer(
                  LocalizationService.of(context).t(
                    'verify_phone_check_code_page_desc',
                  ),
                ),
                // a form container
                verifyPhoneWidgetFormContainer(
                  Column(
                    children: [
                      // a form
                      verifyPhoneWidgetFormInputContainer(
                        _formBuilderWidget,
                      ),
                      // a loading bar
                      if (_state.isRequestPending) LoadingIndicatorWidget(),
                      // a verify code button
                      verifyPhoneWidgetButtonContainer(
                        context,
                        'verify_phone_done_button',
                        () => _verifyPhoneCode(),
                      )
                    ],
                  ),
                ),
                // a resend phone code button
                verifyPhoneWidgetTextButtonContainer(
                  context,
                  () => _openVerifyPhoneNumbePage(),
                  'verify_phone_open_check_phone_page',
                ),
              ].toColumn(),
              backToStarterCallback: () => widget.redirectToMainPage(context,
                  cleanAuthCredentials: true),
            ),
          ),
        );
      },
    );
  }

  void _verifyPhoneCode() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    final formValues = _formBuilderWidget.getFormValues();
    final result = await _state.verifyPhoneCode(
      formValues['code'],
    );

    if (!result.valid) {
      widget.showAlert(
        context,
        'verify_phone_invalid_code',
        title: 'error_occurred',
      );

      return;
    }

    widget.redirectToMainPage(context, cleanAppErrors: true);
    widget.showMessage('verify_phone_verification_successful', context);
  }

  void _openVerifyPhoneNumbePage() {
    widget.hideKeyboard();

    showPlatformDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyPhoneNumberWidget(),
    );
  }
}
