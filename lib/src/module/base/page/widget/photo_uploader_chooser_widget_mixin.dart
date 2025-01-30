import 'package:flutter/material.dart';

import '../../service/model/action_sheet_model.dart';
import 'action_sheet_widget_mixin.dart';
import 'keyboard_widget_mixin.dart';

mixin PhotoUploaderChooserWidgetMixin
    on ActionSheetWidgetMixin, KeyboardWidgetMixin {
  void displayPhotoUploadChooser(
    BuildContext context,
    Function takePhoto,
    Function selectPhoto,
  ) {
    showActionSheet(context, [
      ActionSheetModel(
        label: 'take_photo',
        callback: () {
          hideKeyboard();
          takePhoto();
        },
      ),
      ActionSheetModel(
        label: 'select_photo',
        callback: () {
          hideKeyboard();
          selectPhoto();
        },
      ),
    ]);
  }
}
