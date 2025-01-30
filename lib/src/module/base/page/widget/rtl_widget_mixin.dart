import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

mixin RtlWidgetMixin {
  bool isRtlMode(BuildContext context) {
    return intl.Bidi.isRtlLanguage(
        Localizations.localeOf(context).languageCode);
  }
}
