import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../state/admob_state.dart';

class AdmobBannerWidget extends StatefulWidget {
  @override
  _AdmobBannerWidgetState createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<AdmobBannerWidget> {
  late final AdmobState _state;

  @override
  void initState() {
    super.initState();

    _state = GetIt.instance.get<AdmobState>();
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
      builder: (_) {
        if (!_state.isBannerAvailable) {
          return Container();
        }

        final banner = _state.newBanner;

        return Container(
          width: banner.size.width.toDouble(),
          height: banner.size.height.toDouble(),
          child: FutureBuilder(
            future: banner.load(),
            builder: (_, __) => AdWidget(ad: banner),
          ),
        );
      },
    );
  }
}
