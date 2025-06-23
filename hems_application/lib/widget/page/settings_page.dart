import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/state/locale_notifier.dart';
import 'package:hems_app/state/theme_notifier.dart';
import 'package:provider/provider.dart';

/// Settings Page for the mobile application.
/// 
/// Contains a [Switch] for Dark Mode, a [DropdownButton] for language choice, [TextButton] for importing and exporting home configuration.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    bool isDarkMode = themeNotifier.isDarkMode;
    final appState = AppState();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          context.l10n.darkMode,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.08),
                      Switch(
                        value: isDarkMode,
                        activeColor: Colors.green,
                        onChanged: (value) async {
                          themeNotifier.toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Language',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: DropdownButtonHideUnderline(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2,
                            ),
                          ),
                          child: DropdownButton<Locale>(
                            value: localeNotifier.locale,
                            isExpanded: true,
                            alignment: Alignment.center,
                            icon: const Icon(Icons.arrow_drop_down),
                            dropdownColor: Theme.of(context).cardTheme.color,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(fontSize: 20),
                            items: const [
                              DropdownMenuItem(
                                value: Locale('en'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🇺🇸'),
                                    SizedBox(width: 8),
                                    Flexible(child: Text('English', style: TextStyle(fontSize: 15),)),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: Locale('nl'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🇳🇱'),
                                    SizedBox(width: 8),
                                    Flexible(child: Text('Nederlands', style: TextStyle(fontSize: 15))),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (locale) {
                              if (locale != null) {
                                localeNotifier.setLocale(locale);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    context.l10n.transferTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      bool success = true;

                      try {
                        String encodedString = base64Encode(
                          utf8.encode(jsonEncode(appState.toJson())),
                        );
                        await Clipboard.setData(
                          ClipboardData(text: encodedString),
                        );
                      } catch (_) {
                        success = false;
                      }

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? context.l10n.exportSuccess
                                : context.l10n.exportFail,
                          ),
                        ),
                      );
                    },
                    label: Text(context.l10n.exportData),
                    icon: Icon(Icons.file_upload),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      bool success = true;

                      try {
                        ClipboardData data =
                            (await Clipboard.getData('text/plain'))!;
                        String jsonString = utf8.decode(
                          base64.decode(data.text!),
                        );
                        appState.initFromJson(jsonDecode(jsonString));
                      } catch (_) {
                        success = false;
                      }

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? context.l10n.importSuccess
                                : context.l10n.importFail,
                          ),
                        ),
                      );
                    },
                    label: Text(context.l10n.importData),
                    icon: Icon(Icons.file_download),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
