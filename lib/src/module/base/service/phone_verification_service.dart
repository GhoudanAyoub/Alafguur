import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';
import 'form_validation_service.dart';
import 'model/form/form_element_model.dart';
import 'model/form/form_element_values_model.dart';
import 'model/form/form_validator_model.dart';
import 'model/generic_response_model.dart';
import 'model/phone_country_model.dart';
import 'model/user_phone_model.dart';
import 'model/validator_response.dart';

class PhoneVerificationService {
  final HttpService httpService;
  final AuthService authService;

  PhoneVerificationService({
    required this.httpService,
    required this.authService,
  });

  Future<ValidatorResponse> verifyPhoneCode(
    String code,
  ) async {
    final result =
        await this.httpService.post('validators/verify-sms-code', data: {
      'code': code,
      'userId': authService.authUser?.id,
    });

    return ValidatorResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<GenericResponseModel> verifyPhoneNumber(
    String countryCode,
    String phoneNumber,
  ) async {
    final result = await this.httpService.post('sms-verifications/sms', data: {
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
    });

    return GenericResponseModel.fromJson(result as Map<String, dynamic>);
  }

  Future<List<PhoneCountryModel>> loadPhoneCountries() async {
    final List<dynamic> countries =
        await this.httpService.get('sms-verifications/countries') as List<dynamic>;

    return countries
        .map<PhoneCountryModel>(
            (country) => PhoneCountryModel.fromJson(country as Map<String, dynamic>))
        .toList();
  }

  Future<UserPhoneModel> loadMyPhone() async {
    return UserPhoneModel.fromJson(
      (await this.httpService.get('sms-verifications/phones/me')) as Map<String, dynamic>,
    );
  }

  List<FormElementModel> getPhoneCodeVerificationFormElements() {
    return [
      FormElementModel(
        key: 'code',
        label: 'verify_phone_code_input',
        type: FormElements.text,
        placeholder: 'verify_phone_code_placeholder',
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    ];
  }

  Future<List<FormElementModel>>
      getPhoneNumberVerificationFormElements() async {
    final List<Future<dynamic>> loadingResources = [
      loadPhoneCountries(),
      loadMyPhone(),
    ];

    final List response = await Future.wait(loadingResources);
    final List<PhoneCountryModel> phoneCountryList = response[0] as List<PhoneCountryModel>;
    final UserPhoneModel userPhone = response[1] as UserPhoneModel;

    return [
      FormElementModel(
        key: 'countryCode',
        label: 'verify_country_code_input',
        type: FormElements.radio,
        placeholder: 'verify_country_code_placeholder',
        value: userPhone.countryCode != null ? [userPhone.countryCode] : null,
        values: phoneCountryList
            .map(
              (phoneCountry) => FormElementValuesModel(
                value: phoneCountry.phoneCode,
                title: phoneCountry.title,
              ),
            )
            .toList(),
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
      FormElementModel(
        key: 'phoneNumber',
        label: 'verify_phone_number_input',
        type: FormElements.number,
        placeholder: 'verify_phone_number_placeholder',
        value: userPhone.number != null ? userPhone.number : null,
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
          FormValidatorModel(
            name: FormSyncValidators.number,
            params: {
              FormValidatorParams.min: 0,
            },
            message: 'user_phone_validator_error',
          ),
        ],
      ),
    ];
  }
}
