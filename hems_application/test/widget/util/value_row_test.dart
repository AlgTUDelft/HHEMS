import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/widget/util/value_row.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('No icon test', (tester) async {
    String description = "Power consumption";
    String value = "15 Wh";
    await tester.pumpWidget(
      wrapWithMaterialApp(ValueRow(description: description, value: value)),
    );

    final descriptionFinder = find.text(description);
    final valueFinder = find.text(value);

    expect(descriptionFinder, findsOneWidget);
    expect(valueFinder, findsOneWidget);
  });

  testWidgets('Icon test', (tester) async {
    String description = "Power consumption";
    String value = "15 Wh";
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ValueRow(description: description, value: value, icon: Icons.bolt),
      ),
    );

    final descriptionFinder = find.text(description);
    final valueFinder = find.text(value);
    final iconFinder = find.byIcon(Icons.bolt);

    expect(descriptionFinder, findsOneWidget);
    expect(valueFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);
  });
}
