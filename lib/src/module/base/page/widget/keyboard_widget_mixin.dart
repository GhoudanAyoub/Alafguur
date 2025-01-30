import 'package:flutter/material.dart';

mixin KeyboardWidgetMixin {
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
