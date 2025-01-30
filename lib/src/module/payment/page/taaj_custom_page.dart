import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../base/page/abstract_page.dart';
import '../../base/page/style/common_widget_style.dart';
import '../../base/page/widget/match_action_widget_mixin.dart';
import '../../base/service/localization_service.dart';
import '../../dashboard/page/widget/conversation/dashboard_conversation_widget_mixin.dart';

final serviceLocator = GetIt.instance;

class TaajCustomPage extends AbstractPage
    with MatchActionWidgetMixin, DashboardConversationWidgetMixin {
  const TaajCustomPage({
    Key? key,
    required routeParams,
    required widgetParams,
  }) : super(
          key: key,
          routeParams: routeParams,
          widgetParams: widgetParams,
        );

  @override
  _TaajCustomPageState createState() => _TaajCustomPageState();
}

class _TaajCustomPageState extends State<TaajCustomPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => scaffoldContainer(
        context,
        scrollable: false,
        header: LocalizationService.of(context).t(
          'custom_page_head',
        ),
        body: _taajCustomPage(),
      ),
    );
  }

  _taajCustomPage() {
    return Text(LocalizationService.of(context).t(
      'custom_page_text',
    ));
  }
}
