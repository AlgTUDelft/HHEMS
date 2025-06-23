import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hems_app/model/api/measurement.dart';
import 'package:hems_app/state/stat_collector.dart';
import 'package:hems_app/widget/analytics/consumption_chart.dart';
import '../../testing_utils/wrap_with_material_app.dart';

void main() {
  testWidgets('Displays correctly with empty data', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(ConsumptionChart()));

    final chartFinder = find.byType(BarChart);

    expect(chartFinder, findsOneWidget);
  });

  testWidgets('Displays correctly with data', (tester) async {
    final statCollector = StatCollector();

    statCollector.consumptionData = [
      MapEntry(
        Measurement(100, 'W'),
        DateTime.now().subtract(Duration(seconds: 5)),
      ),
      MapEntry(
        Measurement(200, 'W'),
        DateTime.now().subtract(Duration(seconds: 10)),
      ),
      MapEntry(
        Measurement(300, 'W'),
        DateTime.now().subtract(Duration(seconds: 15)),
      ),
      MapEntry(
        Measurement(400, 'W'),
        DateTime.now().subtract(Duration(seconds: 20)),
      ),
      MapEntry(
        Measurement(500, 'W'),
        DateTime.now().subtract(Duration(seconds: 25)),
      ),
    ];

    await tester.pumpWidget(wrapWithMaterialApp(ConsumptionChart()));

    final chartFinder = find.byType(BarChart);

    expect(chartFinder, findsOneWidget);
  });
}
