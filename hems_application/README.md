# Project Overview
Our application is a user-friendly frontend for the [HHEMS](https://github.com/AlgTUDelft/HHEMS) backend. Hybrid Home Energy Management System (HHEMS) is a system to manage smart energy systems. The aim of the project is to make smart energy systems accessible to people without the technical expertise. Our application's goal is to create a intuitive to use frontend for the project so that it can be used by people who are not tech-savvy.

# Release
Our latest release build with the generated documentation and an android APK package can be found [here](https://gitlab.ewi.tudelft.nl/cse2000-software-project/2024-2025/cluster-w/03d/03d/-/releases/permalink/latest).

# Setup

First, the backend from [HHEMS](https://github.com/AlgTUDelft/HHEMS) needs to be set up. The readme in that repository lists the necessary steps for successfully running the Docker containers for the backend.

Next, the IP address of the backend is required to start the app. Depending on where you are running Docker, this can be achieved by using the following commands: ip addr (Linux), ipconfig (Windows)

Flutter and Dart extensions are required to build the app.

Depending on which platform you are trying to build the app (IOS, Android, Windows, Edge etc.), additional tools might be needed. Run `flutter doctor -v` and follow the steps shown there.

Prior to running the app for the first time or when changes are made to then lib\l10n, run this command:

`flutter gen-l10n`

To run the app, use the following command and make sure HEMS_URL corresponds with the backend:

`flutter run --dart-define=HEMS_URL='<URL for the server>'`

`flutter test --dart-define=HEMS_URL='<URL for the server>'`

`flutter build --dart-define=HEMS_URL='<URL for the server>'`

If any errors or warnings are encountered, refer to the Important Commands sections of the readme first.

# Important Commands

In case of errors, run the following commands:

`flutter doctor -v` to check for missing setups.

`flutter clean` to clean all dependencies.

`flutter pub get` adds all dependencies from pubspec.yaml.

Prior to running the app for the first time or when changes are made to then lib\l10n, run this command:

`flutter gen-l10n`

For running the app, use the following command and make sure HHEMS_URL corresponds with the backend:

`flutter run --dart-define=HHEMS_URL='<your HHEMS_URL>'`

`flutter test --dart-define=HHEMS_URL='<your HHEMS_URL>'`

`flutter build --dart-define=HHEMS_URL='<your HHEMS_URL>'`


# Firebase Notifications

This mobile application makes use of an external Firebase project (console) to send push notifications to users. Its main purpose is to send marketing/promotions/new features notifications to all users of a respective platform (Android/IOS) or all platforms combined.

To create a campaign, in the 'hems-03d' firebase project, go to Run/Messaging/Create your first campaign. Select Firebase Notification messages, enter all notification details and platforms, schedule a date, and then press Review.

Ownership of a Firebase project can be conveniently exchanged. Go to settings, Users and permissions, Add member, press the 3 dots, edit access and change it to Owner.

Permissions: the user will need to accept notification permissions to make use of this feature. 

Dependencies used:   `firebase_core, firebase_messaging, firebase_analytics`

Related classes/config files: `firebase.json, lib\firebase\firebase_msg.dart, lib\firebase\firebase_options.dart`

For further documentation: https://firebase.google.com/docs

# Local Notifications

Informative notifications (i.e. reminders) are handled through Flutter's built-in packages. Currently, the application sends a notification every time a user schedules a job 10 minutes before it starts and 10 minutes before it stops (if applicable). When a schedule is cancelled, so are all related notifications.

All logic related to initializing the notification service, handling permissions, sending instant or scheduled notifications and cancelling them can be found in `lib\service\local_notifications_service.dart`. It also makes use of the timezone package, but for now, the timezone is hardcoded to Europe Brussels as the app is intended for Dutch households and also to avoid having to handle location permissions. In the future, if the plan is to extend outside of the Netherlands, it is recommended to implement this.

Permissions: the user will need to accept notification permissions to make use of this feature. For Android, the uses-permissions and receivers can be found in `android\app\src\main\AndroidManifest.xml`. For IOS, `ios\Runner\AppDelegate.swift` is responsible for the permissions.

Dependencies used: flutter_local_notifications

Related classes/config files: `lib\service\local_notifications_service.dart, android\app\src\main\AndroidManifest.xml, ios\Runner\AppDelegate.swift`

For further documentation: https://pub.dev/packages/flutter_local_notifications

# Language / l10n

The application currently supports 2 languages: Dutch and English. The default language is English upon first opening the app. It can be changed at any time in the Settings page, persisting locally.

Localized strings can be added and removed from the app_en.arb and app_nl.arb files in the `lib/l10n` folder. To add a new language simply create a new .arb file and add the supported locale to the MaterialApp in `lib/main.dart`. 

To automatically generate the classes that expose the localized strings to the code, run this command:
`flutter gen-l10n`

Dependencies used: `intl`

Related folder: `lib\l10n`

For further documentation: https://pub.dev/packages/intl

# Navigation Tabs

Our app frontend is designed using the bottom bar navigation system style in Flutter, containing the following 4 main tabs: 
- Home Tab: The application will always launch on this tab, which displays the rooms created by the user, and analytics including a network diagram of power flow from producers to consumers and a bar chart displaying the overall power consumption in the past minute.
- Schedules Tab: This tab allows users to see upcoming and currently active jobs for timeshifter devices, as well as letting them create such a job. There is also a “Suggestions” widget, currently non-functional, which displays recommendations to the user to aid them in making optimal use of their devices.
- Devices Tab: This tab displays widgets for all of the devices connected to the app. It also allows the user to add/remove devices to/from the app. Most of these devices are interactive in some capacity: choose battery target, choose temperature target, schedule a job for a device, turn on/off lamps etc.
- Settings Tab: This tab provides the user with the ability to switch themes (light/dark mode), change language (English/Dutch) and export/import home configuration to/from clipboard.

# DartDoc Documentation

For autogenerating the documentation in a HTML file, run this command:

`dart doc .`

The file can be found here: `doc\api\index.html `. It contains all the DartDoc documentation (any text that follows `///`) throughout the whole project in an easy-to-read format.

# Icon Integration

Our current icon is made by us using Canva, and is free to use commercially as it only uses basic lines, shapes and fonts.
To change the Icon for all platforms, follow these steps:
- In `assets\icons`, change icon.png and icon_transparent(can be the same as the first icon, but needs to be white on transparent, used for Android Notifications). Do not change the names.
- (For Android 12+) In `android\app\src\main\res`, replace icon_transparent.png in all drawable folders.
- In pubspec.yaml, under 'flutter_launcher_icons:' ,  select the platform you want to generate the icons for by changing their respective boolean to true.
- Run this command: `dart run flutter_launcher_icons`.

Recommended icon sizes: 1024x1024, 512x512
Recommended icon extension: .png

To change the splash screen (background color) when the application launches, follow these steps:
- In pubspec.yaml, under 'flutter_native_splash:', change color (should be in hex). We also suggest changing the color under 'flutter_launcher_icons:' for 'adaptive_icon_background' to be the same.
- Run this command: `dart run flutter_native_splash:create`

Dependencies used: `flutter_native_splash, flutter_launcher_icons`

Related classes/config files: `pubspec.yaml, assets\icons, android\app\src\main\res`

For further documentation: https://pub.dev/packages/flutter_native_splash and https://pub.dev/packages/flutter_launcher_icons

# Testing

Application code is verified by the following categories of tests:
- Unit tests for any methods that do not interact with the backend.
- Integration tests for any methods that communicate directly or indirectly with the backend.
- UI tests for any UI elements (i.e widgets, tabs, buttons, etc.).

Note: Integration tests expect the backend to be running with the basic configuration with Home Assistant configured in the demo configuration. Integration tests are automatically skipped if the server URL is not found in the dart environment. In addition, these tests are tagged with integration which can be used to exclude or exclusively include them when running. 

The --coverage flag can be used to collect test coverage information. This creates an lcov file at coverage/lcov.info. If so desired, lcov can be used to summarize the coverage data or generate an html report showing which parts of the code are covered and which parts are not by tests.

Example commands to run for testing:
```sh
flutter test # run integration and widget tests, skips integration tests
flutter test -x integration # Runs every test except integration tests
flutter test --dart-define=HEMS_URL='<URL for the server>' # run all tests
flutter test --dart-define=HEMS_URL='<URL for the server>' -t integration # Only run the integration tests
flutter test --dart-define=HEMS_URL='<URL for the server>' --coverage # Run all the tests, collect coverage information

lcov --summary coverage/lcov.info # Summarize test coverage information
genhtml coverage/lcov.info --output=coverage # Generate an html coverage report showing which lines are covered and which lines are not.
```

Dependencies used: `lcov` (optional)

Related classes/config files: `test/`

# Pipeline

Our project uses a GitLab CI/CD pipeline to test and build our application. The pipeline runs all the unit and widget tests whenever a merge request is created to ensure the branched to be merged is fully functional. In addition it collects coverage information, so it is possible to see when testing starts to lag behind. Information about the tests such as which tests passed/failed and which lines were covered by tests are uploaded as pipeline artifacts.

In addition to testing, our pipeline builds and deploys our application in the form of a GitLab release whenever a new git tag is created. It builds the application in APK form and generates the documentation. These are then uploaded to GitLab's generic package registry. Finally a release sharing the same name with the tag is generated, with links to both the APK and documentation.

Dependencies used: `junitreport, lcov, zip, curl, release-cli`

Related classes/config files: `.gitlab-ci.yml`

# Guidelines

The following rules are recommended to be followed when further contributing to this repository for consistency purposes:

- Follow the Model-View-Controller structure, the distinction can be see in the folders in lib: model, widget, service subfolders.
- Document important classes and methods using DartDoc (`///`). As it can be seen in already existing documentation, it is important that the first line of documentation in each method/class should be followed by a empty line and that no warnings are thrown when running `dart doc .`.
- When creating new widgets and other UI elements, relate to the `lib\material\themes.dart` file before hardcoding any colors, font styles, font sizes etc.
- Test any new code with their relevant testing procedure: Unit tests, Integration tests and/or UI tests.
