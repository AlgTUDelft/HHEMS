import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/widget/page/devices_page.dart';
import 'package:hems_app/widget/page/home_page.dart';
import 'package:hems_app/widget/page/schedules_page.dart';
import 'package:hems_app/widget/page/settings_page.dart';

/// "Page" that acts as navigation between the different pages available in the app (bottom bar).
///
/// Any new potential pages or addition to the bottom bar shall be added to pages array.
class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AppNavigationState();
  }
}

class _AppNavigationState extends State<AppNavigation> {
  int selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    SchedulesPage(),
    DevicesPage(),
    SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    List<String> pageNames = [
      context.l10n.home,
      context.l10n.schedulesPage,
      context.l10n.yourDevices,
      context.l10n.settings,
    ];

    return Scaffold(
      body: _pages[selectedIndex],
      appBar: AppBar(
        title: Text(
          pageNames[selectedIndex],
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected:
            (newIndex) => setState(() {
              selectedIndex = newIndex;
            }),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: context.l10n.schedulesPage,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree),
            label: context.l10n.devices,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: context.l10n.settings,
          ),
        ],
      ),
    );
  }
}
