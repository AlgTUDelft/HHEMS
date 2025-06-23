import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hems_app/extensions.dart';

class BatteryRingPainter extends CustomPainter {
  final BuildContext context;
  final double chargeLevel;
  final double? targetLevel;

  /// Constructs a new [BatteryRingPainter].
  ///
  /// [chargeLevel] is in range \[0, 1\] , determines how much of the circle should be filled.
  /// [targetLevel] should be in range \[0, 1\] if present. Determines the target state of charge for the battery.
  BatteryRingPainter(this.context, this.chargeLevel, [this.targetLevel]);

  /// Paints a circle showing battery charge and target if present.
  ///
  /// [chargeLevel] determines how much of the circle is filled.
  /// The filled portion of the circle is red if [chargeLevel] is less than 0.2 and green otherwise.
  /// If [targetLevel] is set an arrow is drawn above the circle showing the target.
  /// In addition cancel target button is drawn below the circle.
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width - 2.5 * strokeWidth) / 2;

    Paint baseCircle =
        Paint()
          ..color = const Color.fromARGB(81, 181, 181, 181)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    Paint progressCircle =
        Paint()
          ..color = chargeLevel < 0.2 ? Colors.red : Colors.green
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    Paint targetArrow =
        Paint()
          ..color = Theme.of(context).colorScheme.primary
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    Paint cancelText =
        Paint()..color = Theme.of(context).colorScheme.error;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.75 * pi,
      1.5 * pi,
      false,
      baseCircle,
    );

    double sweepAngle = 1.5 * pi * chargeLevel;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.75 * pi,
      sweepAngle,
      false,
      progressCircle,
    );

    if (targetLevel == null) {
      return;
    }

    double targetAngle = 1.5 * pi * targetLevel!;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.25 * pi + targetAngle);
    canvas.translate(0, size.height / 2);

    canvas.drawLine(
      Offset(0, 0.5 * strokeWidth),
      Offset(-strokeWidth, 1.5 * strokeWidth),
      targetArrow,
    );
    canvas.drawLine(
      Offset(0, 0.5 * strokeWidth),
      Offset(strokeWidth, 1.5 * strokeWidth),
      targetArrow,
    );

    canvas.restore();

    final cancelIcon = Icons.clear;
    final pbuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: TextAlign.center),
    );

    pbuilder.pushStyle(
      ui.TextStyle(foreground: cancelText, fontWeight: FontWeight.bold),
    );
    pbuilder.addText("${context.l10n.resetTarget}\n");
    pbuilder.pushStyle(
      ui.TextStyle(
        fontSize: 25,
        fontFamily: cancelIcon.fontFamily,
        fontWeight: FontWeight.bold,
      ),
    );
    pbuilder.addText(String.fromCharCode(cancelIcon.codePoint));

    canvas.drawParagraph(
      pbuilder.build()..layout(ui.ParagraphConstraints(width: 100)),
      Offset(size.width / 2 - 50, size.height - 35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
