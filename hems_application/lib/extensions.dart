import 'package:flutter/widgets.dart';
import 'package:hems_app/l10n/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
