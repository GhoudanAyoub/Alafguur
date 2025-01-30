import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import 'state/contact_us_state.dart';
import 'widget/settings_page_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class ContactUsPage extends AbstractPage {
  ContactUsPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late final ContactUsState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<ContactUsState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();
    _state.initializeForm(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          showHeaderBackButton: !_state.isMessageSending,
          header: LocalizationService.of(context).t('contact_us_page_title'),
          headerActions: !_state.isPageLoading
              ? [
                  !_state.isMessageSending
                      ? appBarTextButtonContainer(
                          _send,
                          LocalizationService.of(context).t('send'),
                        )
                      : scaffoldHeaderActionLoading(),
                ]
              : null,
          body: !_state.isPageLoading
              ? contactUsPage()
              : SettingsPageSkeletonWidget(),
          scrollable: true,
          backgroundColor: _state.isPageLoading
              ? AppSettingsService.themeCommonScaffoldLightColor
              : null,
        );
      },
    );
  }

  Widget contactUsPage() {
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

  Future<void> _send() async {
    final isFormValid = await _formBuilderWidget.isFormValid();

    if (!isFormValid) {
      widget.showMessage('form_general_error', context);

      return;
    }

    await _state.sendMessage(
      _formBuilderWidget['to']!.value[0],
      _formBuilderWidget['from']!.value,
      _formBuilderWidget['subject']!.value,
      _formBuilderWidget['message']!.value,
    );

    Navigator.pop(context);
    widget.showMessage('contact_us_message_sent', context);
  }
}
