import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/state/app_state.dart';
import 'package:hems_app/widget/device/solar_toggle_switch.dart';
import '../../testing_utils/wrap_with_material_app.dart';

Device solarPanel = Device(deviceId: "0", houseId: 0, type: DeviceType.solar);

void main() {
  testWidgets('Displays correctly', (tester) async {
    final appState = AppState();
    final switchFinder = find.byType(Switch);

    appState.isSolarEnabled = false;

    await tester.pumpWidget(
      wrapWithMaterialApp(SolarToggleSwitch(solarPanel: solarPanel)),
    );
    expect(switchFinder, findsOneWidget);

    appState.isSolarEnabled = true;
    await tester.pump();
    expect(switchFinder, findsOneWidget);
  });
}
