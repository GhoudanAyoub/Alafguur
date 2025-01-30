import 'package:mobx/mobx.dart';

import '../../../base/page/widget/form/form_builder_widget.dart';
import '../../../base/service/model/form/form_element_model.dart';
import '../../../base/service/user_service.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../service/edit_service.dart';
import 'edit_photo_state.dart';

part 'edit_state.g.dart';

class EditState = _EditState with _$EditState;

abstract class _EditState with Store {
  final EditService editService;
  final UserService userService;
  final DashboardUserState dashboardUserState;
  final EditPhotoState editPhotoState;

  @observable
  bool isPageLoading = true;

  @observable
  bool isUserUpdating = false;

  _EditState({
    required this.editService,
    required this.userService,
    required this.dashboardUserState,
    required this.editPhotoState,
  });

  @action
  Future<void> init(FormBuilderWidget formBuilder) async {
    isPageLoading = true;

    try {
      // load both form elements and the user's data
      final List<Future<dynamic>> loadingResources = [];
      loadingResources.add(editPhotoState.init());
      loadingResources.add(editService.getFormElements());

      final List response = await Future.wait(loadingResources);

      formBuilder.registerFormElements(response[1]);
    } catch (error) {
      isPageLoading = false;

      throw error;
    }

    isPageLoading = false;
  }

  /// unsubscribe watchers and clean resources
  void dispose() {
    editPhotoState.dispose();
  }

  @action
  Future<void> editUser(
    List<FormElementModel?> updatesValues,
  ) async {
    isUserUpdating = true;

    try {
      await userService.updateMyQuestions(
        updatesValues,
        isCompleteMode: false,
      );

      // refresh the user's data
      await dashboardUserState.loadUser();
    } catch (error) {
      isUserUpdating = false;

      throw error;
    }

    isUserUpdating = false;
  }

  bool isAvatarValid() {
    if (!editPhotoState.isAvatarRequired() ||
        (editPhotoState.isAvatarRequired() && editPhotoState.avatar != null)) {
      return true;
    }

    return false;
  }
}
