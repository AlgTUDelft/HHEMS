import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';
import 'package:hems_app/state/stat_collector.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({super.key});

  /// Builds the widget.
  ///
  /// [StatCollector] collects and stores consumption data in a list.
  /// The last 60 seconds of data are stored and displayed in the bar chart.
  /// On the y axis is the total consumption of the devices in the house.
  /// On the x axis is the last 60 seconds.
  @override
  Widget build(BuildContext context) {
    final statCollector = StatCollector();
    return ListenableBuilder(
      listenable: statCollector,
      builder: (context, _) {
        return SizedBox(
          height: MediaQuery.of(context).size.width / 1.4,
          width: MediaQuery.of(context).size.width,
          child: BarChart(
            BarChartData(
              maxY:
                  (statCollector.consumptionData.isEmpty
                      ? 0.0
                      : statCollector.consumptionData
                          .map((e) => e.key.value)
                          .max) *
                  1.30,
              barGroups:
                  statCollector.consumptionData.isEmpty
                      ? []
                      : List.generate(statCollector.consumptionData.length, (
                        i,
                      ) {
                        return BarChartGroupData(
                          x:
                              (statCollector.consumptionData.length * 5) -
                              (i * 5),
                          barRods: [
                            BarChartRodData(
                              toY: statCollector.consumptionData[i].key.value,
                              width: 12,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        );
                      }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: Transform.translate(
                    offset: Offset(40, 0),
                    child: Text(context.l10n.consumption),
                  ),
                  sideTitles: SideTitles(showTitles: true, reservedSize: 55),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(context.l10n.seconds),
                  axisNameSize: 40,
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
