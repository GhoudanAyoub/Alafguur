import 'package:flutter/material.dart';

import '../../service/model/user_model.dart';
import '../style/common_widget_style.dart';
import 'distance_widget_mixin.dart';

class UserDistanceWidget extends StatelessWidget with DistanceWidgetMixin {
  final UserModel? userModel;

  UserDistanceWidget({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return infoItemValueContainer(getDistance(userModel!, context)!);
  }
}
