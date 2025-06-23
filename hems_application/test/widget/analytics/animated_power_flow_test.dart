import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/state/stat_collector.dart';
import 'package:hems_app/widget/analytics/animated_power_flow.dart';
import 'package:hems_app/widget/analytics/power_flow_painter.dart';

void main() {
  testWidgets('Displays correctly', (tester) async {
    final statCollector = StatCollector();

    statCollector.consumers = [PowerSink.devices, PowerSink.battery];
    statCollector.producers = [PowerSink.net, PowerSink.solar];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AnimatedPowerFlow(),
      ),
    );

    final painterFinder = find.byType(CustomPaint);
    final iconFinder = find.byType(Icon);

    expect(painterFinder, findsAny);
    expect(iconFinder, findsExactly(4));
  });
}
