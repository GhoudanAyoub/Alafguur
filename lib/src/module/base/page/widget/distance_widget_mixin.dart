import 'package:flutter/material.dart';

import '../../service/localization_service.dart';
import '../../service/model/user_model.dart';

mixin DistanceWidgetMixin {
  String? getDistance(
    UserModel userModel,
    BuildContext context,
  ) {
    if (userModel.distance!.distance! <= 1 &&
        userModel.distance!.unit == 'km') {
      return LocalizationService.of(context).t(
        'within_km',
        searchParams: [
          'value',
        ],
        replaceParams: [
          userModel.distance!.distance.toString(),
        ],
      );
    }

    if (userModel.distance!.distance! <= 1 &&
        userModel.distance!.unit == 'miles') {
      return LocalizationService.of(context).t('within_miles', searchParams: [
        'value',
      ], replaceParams: [
        userModel.distance!.distance.toString(),
      ]);
    }

    if (userModel.distance!.distance! > 1 && userModel.distance!.unit == 'km') {
      return LocalizationService.of(context).t(
        'km_away',
        searchParams: [
          'value',
        ],
        replaceParams: [
          userModel.distance!.distance.toString(),
        ],
      );
    }

    if (userModel.distance!.distance! > 1 &&
        userModel.distance!.unit == 'miles') {
      return LocalizationService.of(context).t(
        'miles_away',
        searchParams: [
          'value',
        ],
        replaceParams: [
          userModel.distance!.distance.toString(),
        ],
      );
    }

    return null;
  }
}
