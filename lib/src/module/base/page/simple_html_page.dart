import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../app/service/app_settings_service.dart';
import '../service/localization_service.dart';
import 'abstract_page.dart';
import 'style/common_widget_style.dart';
import 'style/simple_html_page_style.dart';

/// Simple page containing any HTML content stored in the Skadate translations.
/// Can be used both as a page and a modal body.
class SimpleHtmlPage extends AbstractPage {
  final String headerKey;
  final String contentKey;

  /// [headerKey] - page header translation key
  /// [contentKey] - page content translation key
  const SimpleHtmlPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
    required this.headerKey,
    required this.contentKey,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  State<StatefulWidget> createState() => _SimpleHtmlPageState();
}

class _SimpleHtmlPageState extends State<SimpleHtmlPage> {
  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      backgroundColor: AppSettingsService.themeCommonScaffoldLightColor,
      header: LocalizationService.of(context).t(widget.headerKey),
      scrollable: true,
      body: simpleHtmlPageWrapperContainer(
        Html(
          data: LocalizationService.of(context).t(
            widget.contentKey,
            removeHtmlTags: false,
          ),
          style: simpleHtmlPageHtmlStyleContainer,
        ),
      ),
    );
  }
}
