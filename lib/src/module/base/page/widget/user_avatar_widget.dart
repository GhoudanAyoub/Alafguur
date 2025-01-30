import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../service/model/user_avatar_model.dart';
import '../state/user_avatar_state.dart';
import 'image_loader_widget.dart';

class UserAvatarWidget extends StatefulWidget {
  final bool isUseBigAvatar;
  final double avatarHeight;
  final double avatarWidth;
  final double? noAvatarHeight;
  final double? noAvatarWidth;
  final UserAvatarModel? avatar;
  final bool usePendingAvatar;

  UserAvatarWidget({
    Key? key,
    required this.isUseBigAvatar,
    required this.avatarHeight,
    this.avatar,
    this.avatarWidth = double.infinity,
    this.usePendingAvatar = false,
    this.noAvatarHeight,
    this.noAvatarWidth,
  }) : super(key: key);

  @override
  State createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  late final UserAvatarState _state;

  @override
  void initState() {
    super.initState();
    _state = GetIt.instance.get<UserAvatarState>();
  }

  double _getNoAvatarHeight() {
    return widget.noAvatarHeight ?? widget.avatarHeight;
  }

  double _getNoAvatarWidth() {
    return widget.noAvatarWidth ?? widget.avatarWidth;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.avatar?.active == true ||
        (widget.avatar?.active == false && widget.usePendingAvatar)) {
      return _realAvatar();
    }

    return _defaultAvatar();
  }

  Widget _realAvatar() {
    if (widget.avatar?.active == false && widget.usePendingAvatar) {
      return ImageLoaderWidget(
        imageUrl: widget.isUseBigAvatar
            ? widget.avatar!.pendingBigUrl
            : widget.avatar!.pendingUrl,
        width: widget.avatarWidth,
        height: widget.avatarHeight,
      );
    }

    return ImageLoaderWidget(
      imageUrl:
          widget.isUseBigAvatar ? widget.avatar!.bigUrl : widget.avatar!.url,
      width: widget.avatarWidth,
      height: widget.avatarHeight,
    );
  }

  Widget _defaultAvatar() {
    return ImageLoaderWidget(
      imageUrl: widget.isUseBigAvatar
          ? _state.getBigDefaultAvatar()
          : _state.getDefaultAvatar(),
      width: _getNoAvatarWidth(),
      height: _getNoAvatarHeight(),
    );
  }
}
