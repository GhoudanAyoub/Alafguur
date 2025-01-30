import 'package:collection/collection.dart' show IterableExtension;
import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';

import '../../../base/page/state/root_state.dart';
import '../../../base/service/model/user_avatar_model.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../../base/service/model/user_photo_model.dart';
import '../../../base/service/user_service.dart';
import '../../service/dashboard_user_service.dart';

part 'dashboard_user_state.g.dart';

class DashboardUserState = _DashboardUserState with _$DashboardUserState;

abstract class _DashboardUserState with Store {
  final UserService userService;
  final RootState rootState;
  final DashboardUserService dashboardUserService;

  // the flag indicates that everything related to the user is loaded
  // e.g (server updates, profile, etc)
  @observable
  bool isUserLoaded = false;

  @observable
  UserModel? user;

  @observable
  Position? userLocation;

  @observable
  bool isUserLocationLoading = false;

  @observable
  UserModel? lastChangedProfile;

  _DashboardUserState({
    required this.userService,
    required this.rootState,
    required this.dashboardUserService,
  });

  @action
  Future<void> loadUser() async {
    user = await userService.loadMe(
      rootState.isPluginAvailable('photo'),
    );
  }

  @action
  Future<Position?> loadUserLocation({
    LocationAccuracy accuracy = LocationAccuracy.low,
  }) async {
    try {
      isUserLocationLoading = true;

      userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );

      dashboardUserService.updateLocation(userLocation!);

      rootState.log(
        '[dashboard_user_state+load_user_location] location is loaded',
      );

      return userLocation;
    } catch (error) {
      rootState.log(
        '[dashboard_user_state+load_user_location] location is not loaded - ' +
            error.toString(),
      );
    }

    isUserLocationLoading = false;

    return null;
  }

  @action
  void updateUserAvatar(UserAvatarModel? avatar) {
    final clonedUser = _cloneUser();
    clonedUser.avatar = avatar;
    user = clonedUser;
  }

  @action
  void deleteUserPhoto(dynamic id) {
    final clonedUser = _cloneUser();
    clonedUser.photos =
        clonedUser.photos!.where((photo) => photo.id != id).toList();

    user = clonedUser;
  }

  @action
  void addUserPhoto(UserPhotoModel photo) {
    final clonedUser = _cloneUser();
    clonedUser.photos = [
      photo,
      if (clonedUser.photos != null) ...clonedUser.photos!,
    ];
    user = clonedUser;
  }

  @action
  void updateUserPermissions(List permissions) {
    final clonedUser = _cloneUser();
    clonedUser.permissions = [];

    permissions.forEach((permission) =>
        clonedUser.permissions!.add(UserPermissionModel.fromJson(permission)));

    user = clonedUser;
  }

  /// merge an actual profile data with the last changed one
  UserModel mergeLastChangedProfile(UserModel profile) {
    return UserModel.fromJson({
      ...profile.toJson(),
      ...lastChangedProfile!.toJson(),
    });
  }

  /// get user permission by a name
  UserPermissionModel? getUserPermission(String name) {
    if (user != null) {
      return user!.permissions!.firstWhereOrNull(
        (UserPermissionModel permissionModel) =>
            permissionModel.permission == name,
      );
    }

    return null;
  }

  UserModel _cloneUser() {
    return UserModel.fromJson(user!.toJson());
  }
}
