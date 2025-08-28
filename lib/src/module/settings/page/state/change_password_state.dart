import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../service/change_password_service.dart';

part 'change_password_state.g.dart';

class ChangePasswordState = _ChangePasswordState with _$ChangePasswordState;

abstract class _ChangePasswordState with Store {
  final ChangePasswordService changePasswordService;
  final RootState rootState;

  @observable
  bool isPasswordEditing = false;

  _ChangePasswordState({
    required this.changePasswordService,
    required this.rootState,
  });

  @action
  void initializeForm(FormBuilderWidget formBuilder) {
    formBuilder.registerFormElements(changePasswordService.getFormElements(
      rootState.getSiteSetting('minPasswordLength', 0),
      rootState.getSiteSetting('maxPasswordLength', 0),
    ));
  }

  @action
  Future<void> changePassword(
    String oldPassword,
    String password,
    String repeatPassword,
  ) async {
    isPasswordEditing = true;

    await changePasswordService.changePassword(
      oldPassword,
      password,
      repeatPassword,
    );

    isPasswordEditing = false;
  }
}
