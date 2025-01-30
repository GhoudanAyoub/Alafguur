import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/model/user_model.dart';
import '../../service/join_finalize_service.dart';

part 'join_finalize_state.g.dart';

class JoinFinalizeState = _JoinFinalizeState with _$JoinFinalizeState;

abstract class _JoinFinalizeState with Store {
  final JoinFinalizeService joinFinalizeService;
  final RootState rootState;

  @observable
  bool isPageLoading = true;

  @observable
  bool isUserCreating = false;

  @observable
  bool tosValue = false;

  _JoinFinalizeState({
    required this.joinFinalizeService,
    required this.rootState,
  });

  @action
  Future<void> init(int? sex, FormBuilderWidget formBuilder) async {
    formBuilder
        .registerFormElements(await joinFinalizeService.getFormElements(sex));
    isPageLoading = false;
  }

  bool isTosActive() => rootState.getSiteSetting('isTosActive', false);

  bool isTosValid() => isTosActive() && tosValue || !isTosActive();

  Future<void> createUser(
    UserModel initialValues,
    List<FormElementModel?> finalizeValues,
  ) async {
    isUserCreating = true;

    // create a user
    final String? userToken =
        await joinFinalizeService.createUser(initialValues);

    rootState.setAuthenticated(userToken!);

    // create questions
    await joinFinalizeService.createQuestions(initialValues, finalizeValues);
  }
}
