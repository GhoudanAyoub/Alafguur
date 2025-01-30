import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../font_icons/sk_mobile_font_icons.dart';
import '../../../../../app/service/app_settings_service.dart';
import '../../../service/localization_service.dart';
import '../../state/error/verify_phone_number_state.dart';
import '../../style/common_widget_style.dart';
import '../../style/error/verify_phone_widget_style.dart';
import '../../style/form/form_builder_widget_style.dart';
import '../flushbar_widget_mixin.dart';
import '../keyboard_widget_mixin.dart';
import '../form/form_builder_widget.dart';
import '../loading_indicator_widget.dart';
import '../modal_widget_mixin.dart';
import '../navigation_widget_mixin.dart';
import '../skeleton/blank_page_skeleton_widget.dart';
import 'verify_phone_code_widget.dart';

final serviceLocator = GetIt.instance;

class VerifyPhoneNumberWidget extends StatefulWidget
    with
        NavigationWidgetMixin,
        FlushbarWidgetMixin,
        ModalWidgetMixin,
        KeyboardWidgetMixin {
  @override
  _VerifyPhoneNumberPageState createState() => _VerifyPhoneNumberPageState();
}

class _VerifyPhoneNumberPageState extends State<VerifyPhoneNumberWidget> {
  late final FormBuilderWidget _formBuilderWidget;
  late final VerifyPhoneNumberState _state;

  @override
  void initState() {
    super.initState();

    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state = serviceLocator.get<VerifyPhoneNumberState>();

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
          scrollable: _state.isPageLoading ? false : true,
          body: _state.isPageLoading
              ? BlankPagesSkeletonWidget(
                  formFields: true,
                )
              : _verifyPhoneNumberPage(),
        );
      },
    );
  }

  Widget _verifyPhoneNumberPage() {
    return verifyPhoneWidgetWrapperContainer(
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
              'verify_phone_check_phone_page_desc',
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
                // a sending phone number button
                verifyPhoneWidgetButtonContainer(
                  context,
                  'verify_phone_send_button',
                  () => _verifyPhoneNumber(),
                )
              ],
            ),
          ),
        ].toColumn(),
        backToStarterCallback: () =>
            widget.redirectToMainPage(context, cleanAuthCredentials: true),
      ),
    );
  }

  void _verifyPhoneNumber() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);
      return;
    }

    final formValues = _formBuilderWidget.getFormValues();
    final result = await _state.verifyPhoneNumber(
      formValues['countryCode'][0],
      formValues['phoneNumber'],
    );

    if (!result.success) {
      widget.showAlert(
        context,
        'verify_phone_sms_sent_error',
        title: 'error_occurred',
      );

      return;
    }

    widget.hideKeyboard();

    showPlatformDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyPhoneCodeWidget(),
    );

    widget.showMessage('verify_phone_sms_sent', context);
  }
}
