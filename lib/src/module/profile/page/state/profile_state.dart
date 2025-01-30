import 'package:mobx/mobx.dart';

import '../../../../app/service/auth_service.dart';
import '../../../../app/service/random_service.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/bookmark_profile_service.dart';
import '../../../base/service/model/user_bookmark_model.dart';
import '../../../base/service/model/user_match_action_model.dart';
import '../../../base/service/model/user_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../../base/service/permissions_service.dart';
import '../../../base/service/user_service.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../../video_im/page/state/video_im_state.dart';
import '../../../video_im/service/model/video_im_call_data_model.dart';
import '../../service/model/profile_photo_unit_model.dart';
import '../../service/profile_service.dart';

part 'profile_state.g.dart';

class ProfileState = _ProfileState with _$ProfileState;

abstract class _ProfileState with Store {
  final ProfileService profileService;
  final AuthService authService;
  final VideoImState videoImState;
  final DashboardUserState dashboardUserState;
  final UserService userService;
  final PermissionsService permissionsService;
  final BookmarkProfileService bookmarkProfileService;
  final RandomService randomService;
  final RootState rootState;

  @observable
  int currentPhotoIndex = 0;

  @observable
  bool isPageLoaded = false;

  @observable
  bool isProfileLoaded = false;

  @observable
  UserModel? profile;

  @observable
  UserPermissionModel? permissionViewProfile;

  @observable
  UserPermissionModel? permissionViewPhoto;

  @observable
  UserPermissionModel? permissionVideoImCall;

  @observable
  UserPermissionModel? permissionVideoImTimedCall;

  @observable
  double? actualDislikeIconBound;

  @observable
  double? actualLikeIconBound;

  final int animationDuration = 500;
  final double dislikeIconLowerBound = 0.7;
  final double dislikeIconUpperBound = 1;
  final double likeIconLowerBound = 1;
  final double likeIconUpperBound = 1.1;

  bool isCompatibilityLoaded = false;
  bool isBookmarksLoaded = false;

  int? _profileId;
  List<int?> trackedPhotos = [];
  late ReactionDisposer _userUpdatesWatcherCancellation;
  late ReactionDisposer _lastChangedProfileWatcherCancellation;

  final String _viewProfilePermissionName = 'base_view_profile';
  final String _viewPhotoPermissionName = 'photo_view';
  final String _videoImCallPermissionName = 'videoim_video_im_call';
  final String _videoImTimedCallPermissionName = 'videoim_video_im_timed_call';

  _ProfileState({
    required this.profileService,
    required this.authService,
    required this.videoImState,
    required this.dashboardUserState,
    required this.userService,
    required this.permissionsService,
    required this.bookmarkProfileService,
    required this.randomService,
    required this.rootState,
  });

  @action
  Future<void> init(int profileId) async {
    _profileId = profileId;
    isPageLoaded = dashboardUserState.isUserLoaded;

    if (isPageLoaded) {
      // initial permissions initialization
      _initPermissions();

      // load the profile's data
      isViewProfileAllowed ? _loadProfile() : isProfileLoaded = true;
    }

    // init watchers
    _initUserUpdatesWatcher();
    _initLastChangedProfileWatcher();
  }

  void dispose() {
    _userUpdatesWatcherCancellation();
    _lastChangedProfileWatcherCancellation();
  }

  @action
  void likeProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.matchAction = UserMatchActionModel(
      id: randomService.integer(),
      userId: profile!.id!,
      type: MatchActionTypeEnum.like,
    );
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void dislikeProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.matchAction = UserMatchActionModel(
      id: randomService.integer(),
      userId: profile!.id!,
      type: MatchActionTypeEnum.dislike,
    );
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void removeProfileMatch() {
    final clonedProfile = _cloneProfile();
    clonedProfile.matchAction = null;
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void bookmarkProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.bookmark = UserBookmarkModel(
      id: randomService.integer(),
      user: profile!.id,
    );
    bookmarkProfileService.bookmarkProfile(profile!.id);
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void unbookmarkProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.bookmark = null;
    bookmarkProfileService.unbookmarkProfile(profile!.id);
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void unblockProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.isBlocked = false;
    userService.unblockUser(profile!.id);
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  @action
  void blockProfile() {
    final clonedProfile = _cloneProfile();
    clonedProfile.isBlocked = true;
    userService.blockUser(profile!.id);
    dashboardUserState.lastChangedProfile = clonedProfile;
  }

  /// track photo view (decrease credits, etc)
  void trackPhotoView(
    int index, {
    bool isLimited = true,
  }) {
    // we should not track avatars
    if (!isProfileOwner && isViewPhotoAllowed && index > 0) {
      final List<ProfilePhotoUnitModel> photos = getPhotos(
        isLimited: isLimited,
      );

      if (photos.asMap().containsKey(index) &&
          !trackedPhotos.contains(photos[index].id)) {
        trackedPhotos.add(photos[index].id);
        permissionsService.trackAction(group: 'photo', action: 'view');
      }
    }
  }

  /// watch user updates
  @action
  void _initUserUpdatesWatcher() {
    _userUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.user, (dynamic _) {
      isPageLoaded = true;

      // refresh the permission list
      _initPermissions();

      // load the profile's data when it's not loaded or updated
      (isViewProfileAllowed && profile == null) ||
              (isViewProfileAllowed && isProfileOwner)
          ? _loadProfile()
          : isProfileLoaded = true;
    });
  }

  /// watch last changed profile
  void _initLastChangedProfileWatcher() {
    _lastChangedProfileWatcherCancellation =
        reaction((_) => dashboardUserState.lastChangedProfile, (dynamic _) {
      // synchronize the latest profile's changes
      if (profile != null &&
          dashboardUserState.lastChangedProfile!.id == profile!.id) {
        profile = dashboardUserState.mergeLastChangedProfile(profile!);
      }
    });
  }

  bool get isDislikeAllowed =>
      profile!.matchAction == null ||
      profile!.matchAction!.type == MatchActionTypeEnum.dislike;

  bool get isActionToolbarAllowed {
    return isViewProfileAllowed &&
        !isProfileOwner &&
        isPageLoaded &&
        isProfileLoaded;
  }

  bool get isViewProfileAllowed {
    return isProfileOwner || permissionViewProfile?.isAllowed == true;
  }

  bool get isViewPhotoAllowed {
    return isProfileOwner || permissionViewPhoto?.isAllowed == true;
  }

  bool get isVideoImCallAllowed {
    return !isProfileOwner &&
        (permissionViewPhoto?.isAllowed == true ||
            permissionViewPhoto?.isPromoted == true);
  }

  bool get isViewMorePhotosAllowed {
    int photosLength = profile!.photos != null ? profile!.photos!.length : 0;

    return isViewPhotoAllowed && photosLength > _firstUserPhotosLimit ||
        isProfileOwner;
  }

  bool get isProfileOwner {
    return _profileId == authService.authUser?.id;
  }

  bool get isVideoImCallTracked {
    return videoImState.isCallTrackedForRole(VideoImCallRole.initiator);
  }

  void videoImCallUser() {
    videoImState.call(profile!);
  }

  /// get the user's photos
  List<ProfilePhotoUnitModel> getPhotos({
    bool isLimited = true,
  }) {
    List<ProfilePhotoUnitModel> photos = [];

    // add an avatar
    photos.add(
      ProfilePhotoUnitModel(
        url: profile!.avatar != null
            ? isProfileOwner
                ? profile!.avatar!.pendingBigUrl!
                : profile!.avatar!.bigUrl!
            : rootState.getSiteSetting('bigDefaultAvatar', ''),
        isActive: profile!.avatar != null ? profile!.avatar!.active : true,
        type: ProfilePhotoUnitType.avatar,
      ),
    );

    // add limited number of photos
    if (profile!.photos != null && isViewPhotoAllowed) {
      profile!.photos!
          .sublist(
            0,
            (profile!.photos!.length > _firstUserPhotosLimit && isLimited
                ? _firstUserPhotosLimit
                : null),
          )
          .forEach(
            (photo) => photos.add(
              ProfilePhotoUnitModel(
                url: photo.bigUrl!,
                id: photo.id,
                isActive: photo.approved,
                type: ProfilePhotoUnitType.photo,
              ),
            ),
          );
    }

    return photos;
  }

  int get _firstUserPhotosLimit =>
      rootState.getSiteSetting('profilePhotosLimit', 0);

  @action
  Future<void> _loadProfile() async {
    isProfileLoaded = false;
    currentPhotoIndex = 0;

    final List<String> relations = [];

    if (isViewPhotoAllowed) {
      relations.add('photos');
    }

    if (rootState.isPluginAvailable('bookmarks')) {
      relations.add('bookmark');
      isBookmarksLoaded = true;
    }

    if (rootState.isPluginAvailable('matchmaking')) {
      isCompatibilityLoaded = true;
    }

    profile = await profileService.loadProfile(
      _profileId,
      extraRelations: relations,
    );

    if (!isProfileOwner) {
      actualDislikeIconBound = profile!.matchAction == null ||
              profile!.matchAction!.type == MatchActionTypeEnum.dislike
          ? dislikeIconUpperBound
          : dislikeIconLowerBound;

      actualLikeIconBound = profile!.matchAction != null &&
              profile!.matchAction!.type == MatchActionTypeEnum.like
          ? likeIconUpperBound
          : likeIconLowerBound;
    }

    isProfileLoaded = true;
  }

  UserModel _cloneProfile() {
    return UserModel.fromJson(profile!.toJson());
  }

  void _initPermissions() {
    permissionViewProfile =
        dashboardUserState.getUserPermission(_viewProfilePermissionName);

    permissionViewPhoto =
        dashboardUserState.getUserPermission(_viewPhotoPermissionName);

    permissionVideoImCall =
        dashboardUserState.getUserPermission(_videoImCallPermissionName);

    permissionVideoImTimedCall =
        dashboardUserState.getUserPermission(_videoImTimedCallPermissionName);
  }
}
