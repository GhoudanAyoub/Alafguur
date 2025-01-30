import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/service/localization_service.dart';
import 'state/installation_guide_state.dart';
import 'style/installation_guide_style.dart';

final serviceLocator = GetIt.instance;

class InstallationGuidePage extends AbstractPage {
  const InstallationGuidePage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _InstallationGuidePageState createState() => _InstallationGuidePageState();
}

class _InstallationGuidePageState extends State<InstallationGuidePage> {
  late final InstallationGuideState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<InstallationGuideState>();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      scrollable: true,
      header: LocalizationService.of(context).t(
        'howto_download_pwa',
      ),
      body: _installationGuidePage(),
    );
  }

  Widget _installationGuidePage() {
    return installationGuideWrapperContainer(
      context,
      Column(
        children: <Widget>[
          // step 1
          installationGuideTitleContainer(
            LocalizationService.of(context)
                .t('guide_step1_${_state.platform}_title'),
          ),
          installationGuideDescrContainer(
            LocalizationService.of(context).t(
              'guide_step1_${_state.platform}',
            ),
          ),
          installationGuideImageContainer(
            Image(
              image: AssetImage(
                'assets/image/installation_guide/guide_step1_${_state.platform}.png',
              ),
              fit: BoxFit.cover,
            ),
          ),

          // step 2
          installationGuideTitleContainer(
            LocalizationService.of(context)
                .t('guide_step2_${_state.platform}_title'),
          ),

          installationGuideDescrContainer(
            LocalizationService.of(context).t('guide_step2_${_state.platform}'),
          ),

          installationGuideImageContainer(
            Image(
              image: AssetImage(
                'assets/image/installation_guide/guide_step2_${_state.platform}.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
