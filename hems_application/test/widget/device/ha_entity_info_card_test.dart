import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/widget/device/ha_entity_info_card.dart';
import '../../testing_utils/wrap_with_material_app.dart';

Device entity = Device(
  deviceId: "light.bed_light",
  houseId: 0,
  type: DeviceType.haEntity,
);

void main() {
  testWidgets('Displays correctly', (tester) async {
    Either<Map<String, dynamic>, String>? entityState = Left({
      "attributes": {
        "brightness": 180,
        "color_mode": "color_temp",
        "color_temp": 380,
        "color_temp_kelvin": 2631,
        "effect": "rainbow",
        "effect_list": ["rainbow", "off"],
        "friendly_name": "Bed Light",
        "hs_color": [28.55, 67.974],
        "max_color_temp_kelvin": 6535,
        "max_mireds": 500,
        "min_color_temp_kelvin": 2000,
        "min_mireds": 153,
        "rgb_color": [255, 164, 82],
        "supported_color_modes": ["color_temp", "hs"],
        "supported_features": 4,
        "xy_color": [0.532, 0.388],
      },
      "context": {
        "id": "01JX5GMB27FAJQE3QATSTQ58JN",
        "parent_id": null,
        "user_id": "5a7289fe4a1b4f07a5781fde5cf3b75f",
      },
      "entity_id": "light.bed_light",
      "last_changed": "2025-06-07T15:37:27.367182+00:00",
      "last_reported": "2025-06-07T15:37:27.367182+00:00",
      "last_updated": "2025-06-07T15:37:27.367182+00:00",
      "state": "on",
    });
    await tester.pumpWidget(
      wrapWithMaterialApp(HaEntityInfoCard(entity: entity)),
    );

    final haEntityInfoCardState =
        tester.state(find.byType(HaEntityInfoCard)) as HaEntityInfoCardState;
    haEntityInfoCardState.setState(() {
      haEntityInfoCardState.entityState = entityState;
    });

    await tester.pump();

    final toggleFinder = find.byType(Switch);

    expect(toggleFinder, findsOneWidget);
  });

  testWidgets('Displays error correctly', (tester) async {
    String message = 'not found';

    await tester.pumpWidget(
      wrapWithMaterialApp(HaEntityInfoCard(entity: entity)),
    );

    final haEntityInfoCardState =
        tester.state(find.byType(HaEntityInfoCard)) as HaEntityInfoCardState;
    haEntityInfoCardState.setState(() {
      haEntityInfoCardState.entityState = Right(message);
    });

    await tester.pump();

    final errorFinder = find.textContaining(message);
    expect(errorFinder, findsOne);
  });

  testWidgets('Displays progress correctly', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(HaEntityInfoCard(entity: entity)),
    );

    final solhaEntityInfoCardStatearState =
        tester.state(find.byType(HaEntityInfoCard)) as HaEntityInfoCardState;
    solhaEntityInfoCardStatearState.setState(() {
      solhaEntityInfoCardStatearState.entityState = null;
    });

    await tester.pump();

    final progressFinder = find.bySubtype<ProgressIndicator>();
    expect(progressFinder, findsOne);
  });
}
