import 'package:mobx/mobx.dart';

import '../../../service/complete_account_service.dart';
import '../../widget/form/form_builder_widget.dart';
import '../root_state.dart';

part 'complete_account_state.g.dart';

class CompleteAccountState = _CompleteAccountState with _$CompleteAccountState;

abstract class _CompleteAccountState with Store {
  final RootState rootState;
  final CompleteAccountService completeAccountService;

  @observable
  bool isPageLoading = true;

  @observable
  bool isUserUpdating = false;

  _CompleteAccountState({
    required this.rootState,
    required this.completeAccountService,
  });

  @action
  Future<void> init(FormBuilderWidget formBuilder) async {
    formBuilder.registerFormElements(
      await completeAccountService.getFormElements(),
    );

    isPageLoading = false;
  }

  @action
  Future<void> updateAccount(Map<String, dynamic> formValues) async {
    isUserUpdating = true;

    // update the user's account type
    await completeAccountService.updateAccountType(
      formValues['accountType'].first,
    );

    rootState.cleanAppErrors();
    isUserUpdating = false;
  }
}
