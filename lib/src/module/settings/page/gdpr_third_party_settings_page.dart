import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/style/simple_html_page_style.dart';
import '../../base/service/localization_service.dart';
import 'style/gdpr_third_party_settings_page_style.dart';
import 'style/settings_page_style.dart';
import 'widget/gdpr_manual_deletion_message_widget.dart';

final serviceLocator = GetIt.instance;

class GdprThirdPartySettingsPage extends AbstractPage {
  const GdprThirdPartySettingsPage({
    Key? key,
    required Map<String, dynamic> routeParams,
    required Map<String, dynamic> widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _GdprThirdPartySettingsPageState createState() =>
      _GdprThirdPartySettingsPageState();
}

class _GdprThirdPartySettingsPageState
    extends State<GdprThirdPartySettingsPage> {

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      header: LocalizationService.of(context).t(
        'gdpr_third_party_page_title',
      ),
      scrollable: true,
      body: Column(
        children: [
          formBasedPageContainer(
            Column(
              children: <Widget>[
                formBasedPageDescContainer(
                  LocalizationService.of(context)
                      .t('gdpr_third_party_note_title'),
                  upperCase: true,
                ),
                Html(
                  data: LocalizationService.of(context).t(
                    'gdpr_third_party_note',
                    removeHtmlTags: false,
                  ),
                  style: simpleHtmlPageHtmlStyleContainer,
                ),
              ],
            ),
          ),
          // request manual deletion button
          gdprThirdPartySettingsButtonWrapperContainer(
            settingsPageButtonContainer(
              LocalizationService.of(context).t('gdpr_request_deletion_btn'),
              _requestManualDeletion,
            ),
          ),
        ],
      ),
    );
  }

  /// Request manual third-party data deletion.
  void _requestManualDeletion() {
    showPlatformDialog(
      context: context,
      builder: (_) => GdprManualDeletionMessageWidget(),
    );
  }
}
