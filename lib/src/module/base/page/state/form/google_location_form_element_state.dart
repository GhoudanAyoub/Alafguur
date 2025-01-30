import 'package:mobx/mobx.dart';

import '../../../service/google_location_service.dart';

part 'google_location_form_element_state.g.dart';

class GoogleLocationFormElementState = _GoogleLocationFormElementState
    with _$GoogleLocationFormElementState;

abstract class _GoogleLocationFormElementState with Store {
  final GoogleLocationService googleLocationService;

  @observable
  bool isPageLoading = false;

  @observable
  String locationKeyword = '';

  @observable
  double distance = 0;

  @observable
  ObservableList locations = ObservableList();

  int _searchCounter = 0;

  _GoogleLocationFormElementState({
    required this.googleLocationService,
  });

  @action
  void clearLocations() {
    locationKeyword = '';
    locations.clear();
  }

  @action
  Future<void> loadLocations(String keyword) async {
    locationKeyword = keyword;

    if (locationKeyword == '') {
      locations.clear();

      return;
    }

    isPageLoading = true;
    _searchCounter++;

    // fetch the list of suggested locations
    final List? _locations =
        await googleLocationService.loadLocations(locationKeyword);

    locations.addAll(_locations!);

    _searchCounter--;

    if (_searchCounter == 0) {
      isPageLoading = false;
    }
  }
}
