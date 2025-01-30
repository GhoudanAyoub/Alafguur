import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/service/localization_service.dart';
import '../settings_config.dart';
import 'state/settings_state.dart';
import 'style/settings_page_style.dart';

final serviceLocator = GetIt.instance;

class SettingsPage extends AbstractPage {
  SettingsPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<SettingsState>();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      header: LocalizationService.of(context).t('profile_app_settings'),
      scrollable: true,
      body: Column(
        children: <Widget>[
          // privacy policy
          infoItemContainer(
            settingsPageItemContainer(
              widget,
              LocalizationService.of(context)
                  .t('app_settings_privacy_policy_label'),
            ),
            context,
            header: LocalizationService.of(context).t(
              'app_settings_basic_information_label',
            ),
            innerPaddingVertical: 19,
            backgroundColor: true,
            clickCallback: _pushPrivacyPolicyPage,
          ),

          // terms of use
          infoItemContainer(
            settingsPageItemContainer(
              widget,
              LocalizationService.of(context)
                  .t('app_settings_terms_of_use_label'),
            ),
            context,
            innerPaddingVertical: 19,
            backgroundColor: true,
            displayBorder: false,
            clickCallback: _pushTermsOfUsePage,
          ),

          // gdpr settings
          if (_state.showGdprSettings) ...[
            infoItemContainer(
              settingsPageItemContainer(
                widget,
                LocalizationService.of(context).t('gdpr_user_data_page'),
              ),
              context,
              header: LocalizationService.of(context).t('gdpr_title'),
              innerPaddingVertical: 19,
              backgroundColor: true,
              displayBorder: !_state.showGdprThirdPartySettings ? false : true,
              clickCallback: _pushGdprUserDataSettingsPage,
            ),

            // gdpr third party settings
            if (_state.showGdprThirdPartySettings)
              infoItemContainer(
                settingsPageItemContainer(
                  widget,
                  LocalizationService.of(context).t('gdpr_party_services_page'),
                ),
                context,
                innerPaddingVertical: 19,
                backgroundColor: true,
                displayBorder: false,
                clickCallback: _pushGdprThirdPartySettingsPage,
              ),
          ],

          // email notifications
          if (_state.showEmailSettings)
            infoItemContainer(
              settingsPageItemContainer(
                widget,
                LocalizationService.of(context).t('app_settings_email_label'),
              ),
              context,
              header: LocalizationService.of(context)
                  .t('app_settings_notifications_label'),
              innerPaddingVertical: 22,
              backgroundColor: true,
              clickCallback: _pushEmailSettingsPage,
            ),

          // push notifications
          infoItemContainer(
            settingsPageItemContainer(
              widget,
              LocalizationService.of(context).t('app_settings_push_label'),
            ),
            context,
            innerPaddingVertical: 19,
            backgroundColor: true,
            displayBorder: false,
            clickCallback: _pushPushSettingsPage,
          ),

          // contacts
          if (_state.showContactSettings)
            infoItemContainer(
              settingsPageItemContainer(
                widget,
                LocalizationService.of(context)
                    .t('app_settings_contacts_us_label'),
              ),
              context,
              header: LocalizationService.of(context).t(
                'app_settings_contacts_label',
              ),
              innerPaddingVertical: 19,
              backgroundColor: true,
              displayBorder: false,
              clickCallback: _pushContactUsPage,
            ),

          // account
          infoItemContainer(
            settingsPageItemContainer(
              widget,
              LocalizationService.of(context)
                  .t('app_settings_change_password_label'),
            ),
            context,
            header: LocalizationService.of(context).t(
              'app_settings_account_label',
            ),
            innerPaddingVertical: 19,
            backgroundColor: true,
            displayBorder: !_state.isAdmin,
            clickCallback: _pushChangePasswordPage,
          ),

          // delete account
          if (!_state.isAdmin)
            infoItemContainer(
              settingsPageItemContainer(
                widget,
                LocalizationService.of(context)
                    .t('app_settings_delete_account_button'),
              ),
              context,
              innerPaddingVertical: 19,
              backgroundColor: true,
              displayBorder: false,
              clickCallback: _confirmDeleteAccount,
            ),

          // logout
          settingsPageButtonWrapperContainer(
            Column(
              children: [
                // logout
                settingsPageButtonContainer(
                  LocalizationService.of(context).t('logout'),
                  () => widget.redirectToMainPage(
                    context,
                    cleanAuthCredentials: true,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Confirm the current user deletion.
  void _confirmDeleteAccount() {
    widget.showConfirmation(
      context,
      'app_settings_delete_account_confirmation',
      _deleteAccount,
      title: 'app_settings_delete_account_confirmation_title',
      yesLabel: 'app_settings_delete_account_confirm_button',
      noLabel: 'cancel',
    );
  }

  /// Delete the current user account.
  void _deleteAccount() async {
    _state.deleteCurrentUser();
    widget.redirectToMainPage(
      context,
      cleanAuthCredentials: true,
      unregisterDevice: false,
    );
  }

  void _pushContactUsPage() {
    Navigator.pushNamed(context, SETTINGS_CONTACT_US_URL);
  }

  void _pushChangePasswordPage() {
    Navigator.pushNamed(context, SETTINGS_CHANGE_PASSWORD_URL);
  }

  /// Push privacy policy page onto the navigation stack.
  void _pushPrivacyPolicyPage() {
    Navigator.pushNamed(context, SETTINGS_PRIVACY_POLICY_URL);
  }

  /// Push terms of use page onto the navigation stack.
  void _pushTermsOfUsePage() {
    Navigator.pushNamed(context, SETTINGS_TERMS_OF_USE_URL);
  }

  /// Push GDPR user data settings page.
  void _pushGdprUserDataSettingsPage() {
    Navigator.pushNamed(context, SETTINGS_GDPR_USER_DATA_URL);
  }

  /// Push GDPR third party settings page.
  void _pushGdprThirdPartySettingsPage() {
    Navigator.pushNamed(context, SETTINGS_GDPR_THIRD_PARTY_URL);
  }

  /// Push email settings page onto the navigation stack.
  void _pushEmailSettingsPage() {
    Navigator.pushNamed(context, SETTINGS_EMAIL_NOTIFICATIONS_URL);
  }

  /// Push push notifications settings page onto the navigation stack.
  void _pushPushSettingsPage() {
    Navigator.pushNamed(context, SETTINGS_PUSH_NOTIFICATIONS_URL);
  }
}
