import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';
import '../../base/service/form_validation_service.dart';
import '../../base/service/model/form/form_element_model.dart';
import '../../base/service/model/form/form_element_values_model.dart';
import '../../base/service/model/form/form_validator_model.dart';
import '../../base/service/user_service.dart';

const USER_SEARCH_FILTER = 'user_search_filter';

class DashboardSearchService {
  final HttpService httpService;
  final UserService userService;
  final SharedPreferences sharedPreferences;
  final AuthService authService;

  final String _userSearchRequestName = 'user_search';
  final List<FormElementValuesModel> _genders = [];
  final Map _allSearchQuestions = {};
  String? _preferredGender;

  DashboardSearchService({
    required this.httpService,
    required this.userService,
    required this.sharedPreferences,
    required this.authService,
  });

  /// get a user's defined filter list
  Map? getFilter() {
    String? filter = sharedPreferences.getString(
      _getFilterSettingName()!,
    );

    if (filter != null) {
      return jsonDecode(sharedPreferences.getString(
        _getFilterSettingName()!,
      )!);
    }

    return {};
  }

  /// save a user defined filter list
  void setFilter(Map filter) {
    sharedPreferences.setString(
      _getFilterSettingName()!,
      jsonEncode(filter),
    );
  }

  /// search users
  Future<List?> searchUsers(Map? filter) async {
    // save a received filter in a storage
    setFilter(filter ?? {});

    // cancel a previous request
    httpService.cancelRequestByName(_userSearchRequestName);

    return await httpService.post(
      'users/searches',
      data: {
        'filters': filter ?? {},
        'with[]': [
          'avatar',
        ]
      },
      requestName: _userSearchRequestName,
    );
  }

  /// load form elements from the api
  Future<void> loadFormElements() async {
    // load both form elements and user genders
    final List<Future<dynamic>> loadingResources = [];
    loadingResources.add(httpService.get('search-questions'));
    loadingResources.add(userService.loadGendersAsFormElementsValues());

    final List response = await Future.wait(loadingResources);

    // save form elements the response
    _allSearchQuestions.clear();
    _allSearchQuestions.addAll(response[0]['questions']);

    // save genders from the response
    _genders.clear();
    _genders.addAll(response[1]);

    Map savedFilter = getFilter()!;

    // get a preferred gender either from a storage or from the the response
    _preferredGender = savedFilter.containsKey('match_sex')
        ? savedFilter['match_sex']['value'][0]
        : response[0]['preferredAccountType'].toString();
  }

  /// get form elements
  List<FormElementModel> getFormElements({
    String? userGender,
    required bool showOnlineFormElement,
    required bool showPhotoOnlyFormElement,
  }) {
    final List<FormElementModel> formElementList = [];

    if (userGender == null) {
      userGender = _preferredGender;
    }

    Map? savedFilter = getFilter();

    // add some hardcoded form elements
    formElementList.add(
      FormElementModel(
        group: 'advanced_search_input_section',
        key: 'match_sex',
        type: FormElements.select,
        label: 'looking_for_input',
        values: _genders,
        value: [userGender],
        validators: [
          FormValidatorModel(
            name: FormSyncValidators.require,
          ),
        ],
      ),
    );

    // add the `online only` flag
    if (showOnlineFormElement) {
      formElementList.add(
        FormElementModel(
          group: 'advanced_search_input_section',
          key: 'online',
          type: FormElements.checkbox,
          label: 'online_input',
          value: savedFilter!['online'] != null
              ? savedFilter['online']['value']
              : false,
        ),
      );
    }

    // add the `with a photo only` flag
    if (showPhotoOnlyFormElement) {
      formElementList.add(
        FormElementModel(
          group: 'advanced_search_input_section',
          key: 'with_photo',
          type: FormElements.checkbox,
          label: 'with_photo_input',
          value: savedFilter!['with_photo'] != null
              ? savedFilter['with_photo']['value']
              : false,
        ),
      );
    }

    // register the basic form elements
    _allSearchQuestions[userGender].forEach((questionData) {
      questionData['items'].forEach((question) {
        final formElementModel = FormElementModel.fromJson(question);
        formElementModel.group = questionData['section'];
        // fill the form element either from a storage or from its self
        formElementModel.value = savedFilter![formElementModel.key] != null
            ? savedFilter[formElementModel.key]['value']
            : formElementModel.value;
        formElementList.add(formElementModel);
      });
    });

    return formElementList;
  }

  /// each user will have its own filter
  String? _getFilterSettingName() {
    return sprintf('%s_%s', [
      authService.authUser!.id,
      USER_SEARCH_FILTER,
    ]);
  }
}
