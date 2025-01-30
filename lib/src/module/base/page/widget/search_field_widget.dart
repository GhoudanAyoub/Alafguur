import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/service/app_settings_service.dart';
import '../../service/localization_service.dart';
import '../style/common_widget_style.dart';
import '../style/search_field_widget_style.dart';

typedef OnChangedSearchValueCallback = Function(String value);

class SearchFieldWidget extends StatefulWidget {
  final OnChangedSearchValueCallback onChangedValueCallback;
  final String? value;
  final Color? textColor;
  final Color? iconsColor;
  final Color? placeholderColor;
  final Color? backgroundColor;
  final int delay;
  final String placeholder;
  final Color? borderInputColor;

  const SearchFieldWidget({
    Key? key,
    required this.onChangedValueCallback,
    this.value,
    this.textColor,
    this.iconsColor,
    this.placeholderColor,
    this.backgroundColor,
    this.delay = 1000,
    this.placeholder = 'search',
    this.borderInputColor,
  }) : super(key: key);

  @override
  SearchFieldWidgetState createState() => SearchFieldWidgetState();
}

class SearchFieldWidgetState extends State<SearchFieldWidget> {
  bool _showClearButton = false;

  late final TextEditingController _controller;
  Timer? _timerHandler;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value);

    _controller.addListener(
      () {
        setState(() {
          _showClearButton = _controller.text.length > 0;
        });
      },
    );
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setValue(String value) {
    _controller.text = value;
  }

  String getValue() {
    return _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transparentColor(),
      child: TextField(
        style: searchFieldMaterialTextStyle(widget.textColor),
        controller: _controller,
        onChanged: (String value) {
          // stop a previously started timer
          if (_timerHandler != null) {
            _timerHandler!.cancel();
          }
          _timerHandler = Timer(
            Duration(milliseconds: widget.delay),
            () => widget.onChangedValueCallback(value),
          );
        },
        decoration: searchFieldMaterialDecoration(
          widget.backgroundColor,
          widget.placeholderColor,
          LocalizationService.of(context).t(widget.placeholder),
          _getClearButton(),
          widget.iconsColor,
          widget.borderInputColor,
        ),
      ),
    );
  }

  Widget? _getClearButton() {
    if (!_showClearButton) {
      return null;
    }
    return IconButton(
      onPressed: () {
        widget.onChangedValueCallback('');
        _controller.clear();
      },
      icon: Icon(
        Icons.cancel,
        color: widget.iconsColor ?? AppSettingsService.themeCommonAccentColor,
      ),
      highlightColor: transparentColor(),
      hoverColor: transparentColor(),
      focusColor: transparentColor(),
    );
  }
}
