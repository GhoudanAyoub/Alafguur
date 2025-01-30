
import '../../../../app/service/auth_service.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/form_validation_service.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/model/form/form_validator_model.dart';
import '../../service/gdpr_settings_service.dart';

class GdprSettingsState {
  GdprSettingsService gdprSettingsService;
  AuthService authService;

  /// Current user's display name.
  String get displayName => authService.authUser!.name;

  /// Current user's email.
  String get email => authService.authUser!.email;

  GdprSettingsState({
    required this.gdprSettingsService,
    required this.authService,
  });

  /// Register manual deletion message form elements with the [formBuilder].
  void initializeManualDeletionMessageForm(FormBuilderWidget formBuilder) {
    final elements = <FormElementModel>[
      FormElementModel(
        key: 'manual_deletion_message',
        type: FormElements.textarea,
        placeholder: 'gdpr_message_input_placeholder',
        params: {
          FormElementParams.min: 10,
          FormElementParams.max: 25,
        },
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          )
        ],
      )
    ];

    formBuilder.registerFormElements(elements);
  }

  /// Request user personal data download.
  Future<dynamic> requestUserDataDownload() {
    return gdprSettingsService.requestUserDataDownload();
  }

  /// Request user personal data deletion.
  Future<dynamic> requestUserDataDeletion() {
    return gdprSettingsService.requestUserDataDeletion();
  }

  /// Send manual data deletion [message] to the server admin.
  Future<dynamic> sendManualDataDeletionMessage(String? message) {
    return gdprSettingsService.sendManualDataDeletionMessage(message);
  }
}
