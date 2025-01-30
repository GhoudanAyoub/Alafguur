import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import '../../base/service/user_service.dart';
import 'model/dashboard_tinder_filter_model.dart';

const TINDER_SEARCH_FILTER = 'tinder_search_filter';

class DashboardTinderService {
  final HttpService httpService;
  final UserService userService;
  final SharedPreferences sharedPreferences;
  final AuthService authService;

  DashboardTinderService({
    required this.httpService,
    required this.userService,
    required this.sharedPreferences,
    required this.authService,
  });

  Future<List?> loadUsers(
    List<int?> excludeIds, {
    DashboardTinderFilterModel? filter,
  }) async {
    final basePrams = {
      'with[]': [
        'avatar',
        'matchAction',
      ],
      'excludeIds': excludeIds.join(','),
    };

    if (filter != null) {
      basePrams['filter'] = {
        'distance': filter.locationDistance,
        'location': filter.location,
        'lowerAge': filter.lowerAge,
        'upperAge': filter.upperAge,
        'matchSex': filter.genders.join(','),
      };
    }

    return await httpService.get('tinder-users', queryParameters: basePrams);
  }

  bool get isFilterSetup =>
      sharedPreferences.getString(_getFilterSettingName()!) != null;

  Future<void> saveFilter(Map filterList) async {
    await sharedPreferences.setString(
      _getFilterSettingName()!,
      jsonEncode(filterList),
    );
  }

  Future<void> clearFilter() async {
    await sharedPreferences.remove(_getFilterSettingName()!);
  }

  /// get a user's defined filter list
  DashboardTinderFilterModel? getFilter(
    int defaultTinderFilterLocationMin,
    int defaultTinderFilterLocationMax,
    int defaultTinderFilterDefaultMinAge,
    int defaultTinderFilterDefaultMaxAge,
  ) {
    String? savedFilterString = sharedPreferences.getString(
      _getFilterSettingName()!,
    );

    if (savedFilterString == null) {
      return null;
    }

    Map savedFilter = jsonDecode(savedFilterString);

    int lowerAge = savedFilter['age']['value']['lower'];
    int upperAge = savedFilter['age']['value']['upper'];
    int distance = savedFilter['location']['value']['distance'];

    // check bounds
    if (lowerAge < defaultTinderFilterDefaultMinAge) {
      lowerAge = defaultTinderFilterDefaultMinAge;
    }

    if (upperAge > defaultTinderFilterDefaultMaxAge) {
      upperAge = defaultTinderFilterDefaultMaxAge;
    }

    if (distance < defaultTinderFilterLocationMin ||
        distance > defaultTinderFilterLocationMax) {
      distance = defaultTinderFilterLocationMin;
    }

    return DashboardTinderFilterModel(
      location: savedFilter['location']['value']['location'],
      locationDistance: distance,
      lowerAge: lowerAge,
      upperAge: upperAge,
      genders: savedFilter['match_sex']['value'],
    );
  }

  /// get form elements
  Future<List<FormElementModel>> getFormElements(
    int defaultTinderFilterLocationMin,
    int defaultTinderFilterLocationMax,
    int defaultTinderFilterLocationStep,
    String defaultTinderFilterDistanceUnit,
    int defaultTinderFilterDefaultMinAge,
    int defaultTinderFilterDefaultMaxAge,
  ) async {
    final List<FormElementModel> formElementList = [];
    final genders = await userService.loadGendersAsFormElementsValues();

    final savedFilter = getFilter(
      defaultTinderFilterLocationMin,
      defaultTinderFilterLocationMax,
      defaultTinderFilterDefaultMinAge,
      defaultTinderFilterDefaultMaxAge,
    );

    formElementList.add(
      FormElementModel(
        group: 'base_input_section',
        key: 'location',
        type: FormElements.extendedGoogleMapLocation,
        label: 'location_input',
        placeholder: 'location_input_placeholder',
        params: {
          FormElementParams.min: defaultTinderFilterLocationMin,
          FormElementParams.max: defaultTinderFilterLocationMax,
          FormElementParams.step: defaultTinderFilterLocationStep,
          FormElementParams.unit: defaultTinderFilterDistanceUnit,
        },
        value: {
          'distance':
              savedFilter?.locationDistance ?? defaultTinderFilterLocationMin,
          'location': savedFilter?.location ?? '',
        },
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
        key: 'match_sex',
        type: FormElements.multiSelect,
        label: 'looking_for_input',
        placeholder: 'looking_for_input_placeholder',
        values: genders,
        value: savedFilter?.genders ?? [],
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
        key: 'age',
        type: FormElements.range,
        label: 'age_input',
        placeholder: 'age_input_placeholder',
        params: {
          FormElementParams.min: defaultTinderFilterDefaultMinAge,
          FormElementParams.max: defaultTinderFilterDefaultMaxAge,
        },
        value: {
          'lower': savedFilter?.lowerAge ?? defaultTinderFilterDefaultMinAge,
          'upper': savedFilter?.upperAge ?? defaultTinderFilterDefaultMaxAge,
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

  /// each user will have its own filter
  String? _getFilterSettingName() {
    return sprintf('%s_%s', [
      authService.authUser!.id,
      TINDER_SEARCH_FILTER,
    ]);
  }
}
