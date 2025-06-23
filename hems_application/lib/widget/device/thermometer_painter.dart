import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ThermometerPainter extends CustomPainter {
  final BuildContext context;
  final double temperature;
  final double targetTemperature;

  /// Constructs a new [ThermometerPainter].
  ///
  /// [temperature] should be in range (0, 35)
  /// [targetTemperature] should be in range (0, 35)
  ThermometerPainter(this.context, this.temperature, this.targetTemperature);

  /// Paints a thermometer using [temperature] and [targetTemperature].
  ///
  /// The thermometer is filled up to [temperature], with it being written on the left.
  /// The color of the liquid is blue if [temperature] below 20.0 and red otherwise.
  /// An arrow showing the [targetTemperature] is also drawn, with ti being written on the right.
  @override
  void paint(Canvas canvas, Size size) {
    double border = 4.0;
    double strokeWidth = 4.0;
    double bulbRadius = size.width / 2;
    double columnWidth = bulbRadius / 2;
    Offset bulbCenter = Offset(size.width / 2, size.height - bulbRadius);
    Offset topCenter = Offset(size.width / 2, columnWidth);

    double columnHeight = bulbCenter.dy - bulbRadius - topCenter.dy;

    Paint thermometerBody =
        Paint()..color = Theme.of(context).colorScheme.secondaryFixedDim;

    Paint thermometerLiquid =
        Paint()..color = temperature < 20 ? Theme.of(context).colorScheme.onSecondaryFixedVariant : Theme.of(context).colorScheme.error;

    Paint targetArrow =
        Paint()
          ..color = Theme.of(context).colorScheme.secondary
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    Paint text = Paint()..color = Theme.of(context).colorScheme.secondary;

    canvas.drawCircle(bulbCenter, bulbRadius, thermometerBody);
    canvas.drawCircle(topCenter, columnWidth, thermometerBody);
    canvas.drawRect(
      Rect.fromLTRB(
        size.width / 2 - columnWidth,
        topCenter.dy,
        size.width / 2 + columnWidth,
        bulbCenter.dy,
      ),
      thermometerBody,
    );

    canvas.drawCircle(bulbCenter, bulbRadius - border, thermometerLiquid);

    double tempy =
        topCenter.dy +
        columnHeight * math.max(math.min(1 - temperature / 35, 1), 0);
    double targety =
        topCenter.dy +
        columnHeight * math.max(math.min(1 - targetTemperature / 35, 1), 0);
    double targetx = bulbCenter.dx + bulbRadius + strokeWidth;

    canvas.drawRect(
      Rect.fromLTRB(
        size.width / 2 - columnWidth + border,
        tempy,
        size.width / 2 + columnWidth - border,
        bulbCenter.dy,
      ),
      thermometerLiquid,
    );

    canvas.drawLine(
      Offset(targetx, targety),
      Offset(targetx + strokeWidth, targety + strokeWidth),
      targetArrow,
    );
    canvas.drawLine(
      Offset(targetx, targety),
      Offset(targetx + strokeWidth, targety - strokeWidth),
      targetArrow,
    );

    final pbuilderTarget = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: TextAlign.left),
    );
    pbuilderTarget.pushStyle(
      ui.TextStyle(foreground: text, fontWeight: FontWeight.bold),
    );
    pbuilderTarget.addText("${targetTemperature.toStringAsFixed(1)}°C");
    final targetParagraph =
        pbuilderTarget.build()..layout(ui.ParagraphConstraints(width: 100));

    final pbuilderCur = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: TextAlign.right),
    );
    pbuilderCur.pushStyle(
      ui.TextStyle(foreground: text, fontWeight: FontWeight.bold),
    );
    pbuilderCur.addText("${temperature.toStringAsFixed(1)}°C");
    final curParagraph =
        pbuilderCur.build()..layout(ui.ParagraphConstraints(width: 200));

    canvas.drawParagraph(
      targetParagraph,
      Offset(targetx + 2.5 * strokeWidth, targety - targetParagraph.height / 2),
    );
    canvas.drawParagraph(
      curParagraph,
      Offset(
        bulbCenter.dx - bulbRadius - curParagraph.width,
        tempy - targetParagraph.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
