import 'package:mobx/mobx.dart';

import '../../../../app/service/auth_service.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../service/email_notifications_settings_service.dart';

part 'email_notifications_settings_state.g.dart';

class EmailNotificationsSettingsState = _EmailNotificationsSettingsState
    with _$EmailNotificationsSettingsState;

abstract class _EmailNotificationsSettingsState with Store {
  EmailNotificationsSettingsService emailSettingsService;
  AuthService authService;

  /// True if the question list has been loaded.
  @observable
  bool isFormLoaded = false;

  /// True if the save settings request is pending.
  @observable
  bool isSaveRequestPending = false;

  /// Current user's email.
  String get email => authService.authUser!.email;

  _EmailNotificationsSettingsState({
    required this.emailSettingsService,
    required this.authService,
  });

  /// Load email notifications settings form and register it with the provided
  /// [formBuilder].
  @action
  Future<void> loadAndRegisterForm(FormBuilderWidget formBuilder) async {
    formBuilder.registerFormElements(
      await emailSettingsService.loadNotificationsSettingsFormElements(),
    );

    isFormLoaded = true;
  }

  /// Retrieve email notifications settings values from the provided
  /// [formBuilder] and save them to the server.
  @action
  Future<dynamic> saveSettings(FormBuilderWidget formBuilder) async {
    isSaveRequestPending = true;

    final formElements = formBuilder.getFormElementsList().map(
          (element) => {
            'name': element!.key,
            'value': element.value,
          },
        );

    await emailSettingsService.saveSettings(formElements.toList());

    isSaveRequestPending = false;
  }
}
