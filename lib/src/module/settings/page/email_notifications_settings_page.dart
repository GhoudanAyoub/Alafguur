import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/form/form_builder_widget.dart';
import '../../base/service/localization_service.dart';
import 'state/email_notifications_settings_state.dart';
import 'style/email_notifications_settings_page_style.dart';
import 'widget/settings_page_skeleton_widget.dart';

final serviceLocator = GetIt.instance;

class EmailNotificationsSettingsPage extends AbstractPage {
  const EmailNotificationsSettingsPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _EmailNotificationsSettingsPageState createState() =>
      _EmailNotificationsSettingsPageState();
}

class _EmailNotificationsSettingsPageState
    extends State<EmailNotificationsSettingsPage> {
  late final EmailNotificationsSettingsState _state;
  late final FormBuilderWidget _formBuilderWidget;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<EmailNotificationsSettingsState>();
    _formBuilderWidget = serviceLocator.get<FormBuilderWidget>();

    _state.loadAndRegisterForm(_formBuilderWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return scaffoldContainer(
          context,
          disableContent: _state.isSaveRequestPending,
          header: LocalizationService.of(context).t(
            'email_notifications_page_title',
          ),
          headerActions: _state.isFormLoaded
              ? [
                  _state.isSaveRequestPending
                      ? scaffoldHeaderActionLoading()
                      : appBarTextButtonContainer(
                          _saveSettings,
                          LocalizationService.of(context).t('done'),
                        ),
                ]
              : null,
          body: _state.isFormLoaded
              ? _buildEmailNotificationsSettingsPage()
              : SettingsPageSkeletonWidget(),
        );
      },
    );
  }

  Widget _buildEmailNotificationsSettingsPage() {
    return formBasedPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // page description
          formBasedPageDescContainer(
            LocalizationService.of(context).t(
              'email_notifications_page_description',
            ),
          ),

          // email field
          emailNotificationsSettingsPageEmailContainer(
            infoItemContainer(
              Row(
                children: [
                  infoItemLabelContainer(_state.email),
                ],
              ),
              context,
              header:
                  LocalizationService.of(context).t('app_settings_email_label'),
              backgroundColor: true,
              displayBorder: false,
            ),
          ),

          formBasedPageFormContainer(
            _formBuilderWidget,
          ),
        ],
      ),
    );
  }

  /// Save email notifications settings.
  void _saveSettings() {
    _state.saveSettings(_formBuilderWidget).whenComplete(
          () => widget.showMessage(
            'email_settings_saved',
            context,
          ),
        );
  }
}
