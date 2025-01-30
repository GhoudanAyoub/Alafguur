
import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import 'model/form/form_element_values_model.dart';

class FlagContentService {
  final HttpService httpService;

  FlagContentService({
    required this.httpService,
  });

  /// flag content
  void flagContent(
    int? identityId,
    String entityType,
    String? reason,
  ) {
    httpService.post(
      'flags',
      data: {
        'identityId': identityId,
        'entityType': entityType,
        'reason': reason,
      },
    );
  }

  /// return form elements
  List<FormElementModel> getFormElements() {
    return [
      FormElementModel(
        key: 'reason',
        label: 'flag_input',
        type: FormElements.select,
        placeholder: 'reason',
        values: [
          FormElementValuesModel(title: 'flag_as_spam', value: 'spam'),
          FormElementValuesModel(title: 'flag_as_offence', value: 'offence'),
          FormElementValuesModel(title: 'flag_as_illegal', value: 'illegal'),
        ],
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }
}
