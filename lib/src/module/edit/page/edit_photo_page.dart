import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../app/service/app_settings_service.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/service/localization_service.dart';
import 'state/edit_photo_state.dart';
import 'widget/edit_photo_skeleton_widget.dart';
import 'widget/edit_photo_widget.dart';

final serviceLocator = GetIt.instance;
final editPhotoStateKey = GlobalKey<EditPhotoWidgetState>();

class EditPhotoPage extends AbstractPage {
  const EditPhotoPage({Key? key, required routeParams, required widgetParams})
      : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _EditPhotoState createState() => _EditPhotoState();
}

class _EditPhotoState extends State<EditPhotoPage> {
  late final EditPhotoState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<EditPhotoState>();
    _state.init();
  }

  @override
  void dispose() {
    _state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        header: LocalizationService.of(context).t(
          'edit_user_photos_page_header',
        ),
        headerActions: !_state.isPageLoading
            ? [
                Material(
                  color: transparentColor(),
                  child: IconButton(
                    onPressed: () => _showAllActions(),
                    icon: Icon(Icons.more_vert),
                  ),
                ),
              ]
            : null,
        body: _state.isPageLoading
            ? EditPhotoSkeletonWidget()
            : EditPhotoWidget(key: editPhotoStateKey),
        scrollable: _state.isPageLoading ? true : false,
        backgroundColor: _state.isPageLoading
            ? AppSettingsService.themeCommonScaffoldLightColor
            : null,
      ),
    );
  }

  _showAllActions() {
    editPhotoStateKey.currentState!.showAllActions();
  }
}
