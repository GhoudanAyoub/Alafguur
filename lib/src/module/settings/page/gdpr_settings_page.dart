import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/service/localization_service.dart';
import '../../edit/edit_config.dart';
import 'state/gdpr_settings_state.dart';
import 'style/gdpr_settings_page_style.dart';
import 'style/settings_page_style.dart';

final serviceLocator = GetIt.instance;

class GdprSettingsPage extends AbstractPage {
  const GdprSettingsPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _GdprSettingsPageState createState() => _GdprSettingsPageState();
}

class _GdprSettingsPageState extends State<GdprSettingsPage> {
  late final GdprSettingsState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<GdprSettingsState>();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      header: LocalizationService.of(context).t(
        'gdpr_user_data_page_title',
      ),
      scrollable: true,
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              gdprSettingsPageTextWrapperContainer(
                gdprSettingsPageTextContainer(
                  LocalizationService.of(context).t('gdpr_user_data_note'),
                ),
              ),

              // name field
              infoItemContainer(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoItemLabelContainer(
                      LocalizationService.of(context)
                          .t('gdpr_user_displayName'),
                    ),
                    infoItemValueContainer(
                      _state.displayName,
                    ),
                  ],
                ),
                context,
                backgroundColor: true,
              ),

              // password field
              infoItemContainer(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoItemLabelContainer(
                      LocalizationService.of(context).t('gdpr_user_password'),
                    ),
                    infoItemValueContainer(
                      LocalizationService.of(context)
                          .t('gdpr_user_password_value'),
                    ),
                  ],
                ),
                context,
                backgroundColor: true,
              ),

              // username field
              infoItemContainer(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoItemLabelContainer(
                      LocalizationService.of(context).t('gdpr_user_username'),
                    ),
                    infoItemValueContainer(
                      _state.displayName,
                    ),
                  ],
                ),
                context,
                backgroundColor: true,
              ),

              // email field
              infoItemContainer(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoItemLabelContainer(
                      LocalizationService.of(context).t('gdpr_user_email'),
                    ),
                    infoItemValueContainer(
                      _state.email,
                    ),
                  ],
                ),
                context,
                backgroundColor: true,
                displayBorder: false,
              ),

              // edit profile button
              gdprSettingsPageEditButtonWrapperContainer(
                settingsPageButtonContainer(
                  LocalizationService.of(context).t('gdpr_edit_profile'),
                  _pushEditProfilePage,
                ),
              ),
            ],
          ),
          settingsPageButtonWrapperContainer(
            Column(
              children: [
                // request download button
                settingsPageButtonContainer(
                  LocalizationService.of(context).t(
                    'gdpr_user_data_download_btn',
                  ),
                  _requestDownload,
                ),

                // request deletion button
                settingsPageButtonContainer(
                  LocalizationService.of(context).t(
                    'gdpr_user_data_deletion_btn',
                  ),
                  _requestDeletion,
                  negative: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Push edit profile page onto the navigation stack.
  void _pushEditProfilePage() {
    Navigator.pushNamed(context, EDIT_MAIN_URL);
  }

  /// Send user data download request.
  void _requestDownload() {
    _state.requestUserDataDownload();
    widget.showMessage('gdpr_request_download_feedback', context);
  }

  /// Send user data deletion request.
  void _requestDeletion() {
    _state.requestUserDataDeletion();
    widget.showMessage('gdpr_request_deletion_feedback', context);
  }
}
