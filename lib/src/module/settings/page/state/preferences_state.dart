import 'package:mobx/mobx.dart';

import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../service/preferences_service.dart';

part 'preferences_state.g.dart';

class PreferencesState = _PreferencesState with _$PreferencesState;

abstract class _PreferencesState with Store {
  final PreferencesService preferencesService;

  /// True if preferences section is initialized.
  @observable
  bool isSectionInitialized = false;

  /// True if save preferences request is pending.
  @observable
  bool isSaveRequestPending = false;

  _PreferencesState({
    required this.preferencesService,
  });

  /// Initialize the [formBuilder] with questions from the given [section].
  @action
  Future<void> initializeSection(
    String section,
    FormBuilderWidget formBuilder,
  ) async {
    final questions = await preferencesService.loadSectionFormElements(section);

    // Put all questions into the same group.
    questions.forEach(
      (question) {
        question.group = 'preferences_page_description';
      },
    );

    formBuilder.registerFormElements(questions);

    isSectionInitialized = true;
  }

  /// Retrieve preference values from the [formBuilder] and save them to the
  /// server.
  @action
  Future<void> save(FormBuilderWidget formBuilder) async {
    isSaveRequestPending = true;

    final preferences = formBuilder.getFormElementsList().map(
          (element) => {
            'name': element!.key,
            'value': element.value,
          },
        );

    await preferencesService.savePreferences(preferences.toList());

    isSaveRequestPending = false;
  }
}
