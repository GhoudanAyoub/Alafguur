import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../../../../app/service/random_service.dart';
import '../../../base/exception/file_uploader/file_uploader_exception.dart';
import '../../../base/page/state/root_state.dart';
import '../../../base/service/file_uploader_service.dart';
import '../../../base/service/localization_service.dart';
import '../../../base/service/model/photo_viewer_model.dart';
import '../../../base/service/model/user_avatar_model.dart';
import '../../../base/service/model/user_permission_model.dart';
import '../../../base/service/model/user_photo_model.dart';
import '../../../base/utility/image_utility.dart';
import '../../../dashboard/page/state/dashboard_user_state.dart';
import '../../service/edit_photo_service.dart';
import '../../service/model/edit_photo_unit_model.dart';

part 'edit_photo_state.g.dart';

class EditPhotoState = _EditPhotoState with _$EditPhotoState;

abstract class _EditPhotoState with Store {
  final DashboardUserState dashboardUserState;
  final RootState rootState;
  final EditPhotoService editPhotoService;
  final FileUploaderService fileUploaderService;
  final LocalizationService localizationService;
  final RandomService randomService;
  final ImageUtility imageUtility;

  final int avatarIndex = 0;

  @observable
  bool isPageLoading = false;

  @observable
  EditPhotoUnitModel? avatar;

  @observable
  List<EditPhotoUnitModel> photos = [];

  @observable
  UserPermissionModel? permission;

  int _initializations = 0;
  late ReactionDisposer _userUpdatesWatcherCancellation;
  final String _addPhotoPermissionName = 'photo_upload';

  _EditPhotoState({
    required this.dashboardUserState,
    required this.rootState,
    required this.editPhotoService,
    required this.fileUploaderService,
    required this.localizationService,
    required this.randomService,
    required this.imageUtility,
  });

  @action
  Future<void> init() async {
    _initializations++;

    // the state was already initialized
    if (_initializations == 1) {
      isPageLoading = true;

      await dashboardUserState.loadUser();

      // extract avatar and photos from the user's data
      _initUserAvatar();
      _initUserPhotos();

      // initial permissions initialization
      permission =
          dashboardUserState.getUserPermission(_addPhotoPermissionName);

      // init watchers
      _initUserUpdatesWatcher();

      isPageLoading = false;
    }
  }

  void dispose() {
    if (_initializations > 0) {
      _initializations--;
    }

    // we don't have any active client
    if (_initializations == 0) {
      _userUpdatesWatcherCancellation();
    }
  }

  /// watch user updates
  void _initUserUpdatesWatcher() {
    _userUpdatesWatcherCancellation =
        reaction((_) => dashboardUserState.user, (dynamic _) {
      // refresh the permission
      permission =
          dashboardUserState.getUserPermission(_addPhotoPermissionName);
    });
  }

  @action
  void deleteAvatar() {
    editPhotoService.deleteAvatar(avatar!.id);

    dashboardUserState.updateUserAvatar(null);

    avatar = EditPhotoUnitModel(
      id: null,
      url: rootState.getSiteSetting('defaultAvatar', ''),
      bigUrl: rootState.getSiteSetting('bigDefaultAvatar', ''),
      isPending: false,
      type: EditPhotoUnitType.avatar,
      isActive: true,
    );
  }

  @action
  void deletePhoto(EditPhotoUnitModel photo) {
    editPhotoService.deletePhoto(photo.id);
    dashboardUserState.deleteUserPhoto(photo.id);

    // delete the photo from the local list
    photos = photos.where((userPhoto) => userPhoto.id != photo.id).toList();
  }

  @action
  Future<void> makePhotoAsAvatar(EditPhotoUnitModel photo) async {
    // add a fake avatar
    avatar = EditPhotoUnitModel(
      id: photo.id,
      url: photo.url,
      bigUrl: photo.bigUrl,
      isPending: true,
      type: EditPhotoUnitType.avatar,
    );

    try {
      final uploadedAvatar = await editPhotoService.makePhotoAsAvatar(photo.id);

      // refresh the faked avatar
      _refreshAvatar(uploadedAvatar);
    } catch (error) {
      // remove the faked avatar
      avatar = null;

      throw error;
    }
  }

  /// start photo uploading
  @action
  Future<String?> uploadPhoto(PickedFile file) async {
    final String fakedPhotoId = randomService.string();
    final photoBytes = await file.readAsBytes();
    final mimeType = imageUtility.getMimeType(file.path, photoBytes);

    // add a fake photo
    photos = [
      EditPhotoUnitModel(
        id: fakedPhotoId,
        bytes: photoBytes,
        isPending: true,
        type: EditPhotoUnitType.photo,
      ),
      ...photos
    ];

    final double maxUploadSize = double.parse(
      rootState.getSiteSetting('photoMaxUploadSize', 0).toString(),
    );

    String? errorMessage;

    try {
      final uploadResult = await fileUploaderService.uploadBytes(
        'photos',
        photoBytes,
        'photo.${imageUtility.getImageExtension(mimeType!)}',
        contentType: mimeType,
        maxUploadSize: maxUploadSize,
      );
      final uploadedPhoto = UserPhotoModel.fromJson(uploadResult);

      // refresh the faked photo
      _refreshPhotos(fakedPhotoId, uploadedPhoto);
    } on FileUploaderException catch (error) {
      errorMessage = fileUploaderService.getFailedUploadingErrorMessage(
        error,
        maxUploadSize,
      );

      // remove the faked photo from the list
      photos = photos.where((photo) => photo.id != fakedPhotoId).toList();
    }

    return errorMessage;
  }

  /// start avatar uploading
  @action
  Future<String?> uploadAvatar(PickedFile file) async {
    final avatarBytes = await file.readAsBytes();
    final mimeType = imageUtility.getMimeType(file.path, avatarBytes);

    // add a fake avatar
    avatar = EditPhotoUnitModel(
      bytes: avatarBytes,
      isPending: true,
      type: EditPhotoUnitType.avatar,
    );

    final double maxUploadSize = double.parse(
      rootState.getSiteSetting('avatarMaxUploadSize', 0).toString(),
    );

    String? errorMessage;

    try {
      final uploadResult = await fileUploaderService.uploadBytes(
        'avatars/me',
        avatarBytes,
        'avatar.${imageUtility.getImageExtension(mimeType!)}',
        contentType: mimeType,
        maxUploadSize: maxUploadSize,
      );
      final uploadedAvatar = UserAvatarModel.fromJson(uploadResult);

      // refresh the faked avatar
      _refreshAvatar(uploadedAvatar);
    } on FileUploaderException catch (error) {
      errorMessage = fileUploaderService.getFailedUploadingErrorMessage(
          error, maxUploadSize);

      // remove the faked avatar
      avatar = null;
    }

    return errorMessage;
  }

  /// choose an image to upload
  Future<PickedFile?> chooseImage(
    bool useCamera,
  ) async {
    try {
      final image = await fileUploaderService.showPhotoUploaderDialog(
        useCamera: useCamera,
      );

      if (image != null &&
          imageUtility.isValidImage(
            imageUtility.getMimeType(image.path, await image.readAsBytes()),
          )) {
        return image;
      }
    } catch (error) {
      rootState.log(
          '[edit_photo_state+choose_image] error choosing a photo: ${error.toString()}');
    }

    return null;
  }

  bool isAvatarRequired() =>
      rootState.getSiteSetting('isAvatarRequired', false);

  bool isAvatarDeletingAllowed() {
    if (avatar != null &&
        avatar!.id != null &&
        !isAvatarRequired() &&
        !avatar!.isPending!) {
      return true;
    }

    return false;
  }

  bool isAvatarSlot(int index) {
    return index == avatarIndex;
  }

  bool isExtraSlot(
    int index,
    bool isPreviewMode,
    int maxPreviewSlots,
  ) {
    return isPreviewMode && index == maxPreviewSlots - 1;
  }

  String? getApprovalMessage() {
    // collect a list of not active photos
    final List<EditPhotoUnitModel> notActivePhotos = photos.isNotEmpty
        ? photos.where((userPhoto) => !userPhoto.isActive!).toList()
        : [];

    if (notActivePhotos.isNotEmpty &&
        avatar != null &&
        avatar!.isActive == false) {
      return localizationService.t(
        'avatar_and_photos_approval_text',
        searchParams: [
          'photos',
        ],
        replaceParams: [
          notActivePhotos.length.toString(),
        ],
      );
    }

    if (notActivePhotos.isNotEmpty) {
      return localizationService.t(
        'photos_approval_text',
        searchParams: [
          'photos',
        ],
        replaceParams: [
          notActivePhotos.length.toString(),
        ],
      );
    }

    if (avatar != null && avatar!.isActive == false) {
      return localizationService.t('avatar_approval_text');
    }

    return null;
  }

  /// get an image by it's index
  EditPhotoUnitModel? getImageByIndex(int index) {
    // check the user avatar
    if (index == avatarIndex) {
      return avatar ?? null;
    }

    // make sure we have photo by received index
    if (photos.isNotEmpty && photos.asMap().containsKey(index - 1)) {
      return photos[index - 1];
    }

    return null;
  }

  /// return an actual number of available slots
  int getMaxSlotsCount(int minSlots, int slotsPerRow) {
    int photosCount = 1; // including the avatar slot

    photosCount += photos.length;

    if (photosCount < minSlots) {
      return minSlots;
    }

    // we need to calculate the number of extra slots to be added
    photosCount += (slotsPerRow - photosCount % slotsPerRow);

    return photosCount;
  }

  /// generate a full list of photos for viewing
  List<PhotoViewerModel> getPhotoList() {
    List<PhotoViewerModel> processedPhotos = [];

    if (avatar != null) {
      avatar!.isPending!
          ? processedPhotos.add(PhotoViewerModel(bytes: avatar!.bytes))
          : processedPhotos.add(PhotoViewerModel(url: avatar!.bigUrl));
    }

    if (photos.isNotEmpty) {
      processedPhotos = [
        ...processedPhotos,
        ...photos
            .map(
              (photo) => photo.isPending!
                  ? PhotoViewerModel(bytes: photo.bytes)
                  : PhotoViewerModel(url: photo.bigUrl),
            )
            .toList(),
      ];
    }

    return processedPhotos;
  }

  @action
  _refreshPhotos(
    dynamic fakedPhotoId,
    UserPhotoModel uploadedPhoto,
  ) {
    dashboardUserState.addUserPhoto(uploadedPhoto);
    photos = photos.map((photo) {
      if (photo.id == fakedPhotoId) {
        return EditPhotoUnitModel(
          id: uploadedPhoto.id,
          url: uploadedPhoto.url,
          bigUrl: uploadedPhoto.bigUrl,
          isPending: false,
          type: EditPhotoUnitType.photo,
          isActive: uploadedPhoto.approved,
        );
      }

      return photo;
    }).toList();
  }

  @action
  _refreshAvatar(UserAvatarModel uploadedAvatar) {
    dashboardUserState.updateUserAvatar(uploadedAvatar);
    avatar = EditPhotoUnitModel(
      id: uploadedAvatar.id,
      url: dashboardUserState.user!.avatar!.pendingUrl,
      bigUrl: dashboardUserState.user!.avatar!.pendingBigUrl,
      isPending: false,
      type: EditPhotoUnitType.avatar,
      isActive: uploadedAvatar.active,
    );
  }

  @action
  void _initUserAvatar() {
    if (dashboardUserState.user!.avatar != null) {
      avatar = EditPhotoUnitModel(
        id: dashboardUserState.user!.avatar!.id,
        url: dashboardUserState.user!.avatar!.pendingUrl,
        bigUrl: dashboardUserState.user!.avatar!.pendingBigUrl,
        isPending: false,
        type: EditPhotoUnitType.avatar,
        isActive: dashboardUserState.user!.avatar!.active,
      );

      return;
    }

    avatar = EditPhotoUnitModel(
      id: null,
      url: rootState.getSiteSetting('defaultAvatar', ''),
      bigUrl: rootState.getSiteSetting('bigDefaultAvatar', ''),
      isPending: false,
      type: EditPhotoUnitType.avatar,
      isActive: true,
    );
  }

  @action
  void _initUserPhotos() {
    if (dashboardUserState.user!.photos != null) {
      photos = dashboardUserState.user!.photos!.map((photo) {
        return EditPhotoUnitModel(
          id: photo.id,
          url: photo.url,
          bigUrl: photo.bigUrl,
          isPending: false,
          type: EditPhotoUnitType.photo,
          isActive: photo.approved,
        );
      }).toList();

      return;
    }

    photos = [];
  }
}
