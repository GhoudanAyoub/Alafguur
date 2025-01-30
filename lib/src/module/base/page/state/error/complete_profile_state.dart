import 'package:mobx/mobx.dart';

import '../../../service/complete_profile_service.dart';
import '../../../service/model/form/form_element_model.dart';
import '../../../service/user_service.dart';
import '../../widget/form/form_builder_widget.dart';
import '../root_state.dart';

part 'complete_profile_state.g.dart';

class CompleteProfileState = _CompleteProfileState with _$CompleteProfileState;

abstract class _CompleteProfileState with Store {
  final RootState rootState;
  final CompleteProfileService completeProfileService;
  final UserService userService;

  @observable
  bool isPageLoading = true;

  @observable
  bool isUserUpdating = false;

  _CompleteProfileState({
    required this.rootState,
    required this.completeProfileService,
    required this.userService,
  });

  @action
  Future<void> init(FormBuilderWidget formBuilder) async {
    formBuilder
        .registerFormElements(await completeProfileService.getFormElements());
    isPageLoading = false;
  }

  @action
  Future<void> updateUser(List<FormElementModel?> updatedValues) async {
    isUserUpdating = true;

    // update the user's questions
    await userService.updateMyQuestions(updatedValues);

    rootState.cleanAppErrors();
    isUserUpdating = false;
  }
}
