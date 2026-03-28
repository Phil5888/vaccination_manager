import 'package:flutter/widgets.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';

String getLanguageLabel(BuildContext context, dynamic localeOrCode, {bool withFlag = false}) {
  final local = AppLocalizations.of(context)!;

  String code;
  if (localeOrCode is Locale) {
    code = localeOrCode.languageCode;
  } else if (localeOrCode is String) {
    code = localeOrCode;
  } else {
    return localeOrCode.toString();
  }

  switch (code) {
    case 'de':
      return '${withFlag ? '🇩🇪 ' : ''}${local.german}';
    case 'en':
      return '${withFlag ? '🇺🇸 ' : ''}${local.english}';
    default:
      return code;
  }
}
