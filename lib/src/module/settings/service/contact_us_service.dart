import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_element_values_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import 'model/contact_us_department_model.dart';

class ContactUsService {
  final HttpService httpService;

  ContactUsService({
    required this.httpService,
  });

  Future<List<FormElementModel>> getFormElements() async {
    final departments = await loadDepartments();
    final List<FormElementModel> formElementList = [];

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'to',
        type: FormElements.radio,
        label: 'contact_us_to_input',
        placeholder: 'contact_us_to_input_placeholder',
        values: departments
            .map(
              (department) => FormElementValuesModel(
                value: department.id,
                title: department.name,
              ),
            )
            .toList(),
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    );

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'from',
        type: FormElements.email,
        label: 'contact_us_from_input',
        placeholder: 'contact_us_from_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.email,
          ),
        ],
      ),
    );

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'subject',
        type: FormElements.text,
        label: 'contact_us_subject_input',
        placeholder: 'contact_us_subject_input_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    );

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'message',
        type: FormElements.textarea,
        label: 'contact_us_message_input',
        placeholder: 'contact_us_message_input_placeholder',
        params: {
          FormElementParams.min: 10,
          FormElementParams.max: 20,
        },
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    );

    return formElementList;
  }

  /// load available departments
  Future<List<ContactUsDepartmentModel>> loadDepartments() async {
    final List<dynamic> genders =
        await this.httpService.get('contact-us/departments');

    return genders
        .map<ContactUsDepartmentModel>(
            (gender) => ContactUsDepartmentModel.fromJson(gender))
        .toList();
  }

  Future<void> sendMessage(
    Map messageParams,
  ) async {
    await httpService.post(
      'contact-us/',
      data: messageParams,
    );
  }
}
