import 'package:flutter/material.dart';

/// Defines the 4 supported sources and consumers of power.
enum PowerSink { devices, solar, battery, net }

extension PowerSinkExtension on PowerSink {
  /// Returns the [Offset] of the given [PowerSink] in the diagram.
  /// 
  /// Each is on one of the corners of a "square diamond" shape.
  /// The modifications with value 50 make the points at the center of their icons.
  Offset offset(Size size) {
    return switch (this) {
      PowerSink.solar => Offset(size.width - 50, size.height / 2),
      PowerSink.battery => Offset(50, size.height / 2),
      PowerSink.devices => Offset(size.width / 2, 50),
      PowerSink.net => Offset(size.width / 2, size.height - 50),
    };
  }

  /// Returns the [Color] associated with this [PowerSink].
  Color color() {
    return switch (this) {
      PowerSink.solar => Colors.amber,
      PowerSink.battery => Colors.green,
      PowerSink.devices => Colors.grey,
      PowerSink.net => Colors.blue,
    };
  }
}

class PowerFlowPainter extends CustomPainter {
  double progress;
  List<PowerSink> producers;
  List<PowerSink> consumers;

  /// Lines and traveling thunderbolt icons between the four corners of a diamond shape.
  ///
  /// [progress] indicates how far along the path the thunderbolts are.
  /// [producers] indicates from what points the thunderbolts and lines should originate.
  /// The lines and thunderbolts end at the [consumers].
  PowerFlowPainter({
    required this.progress,
    required this.consumers,
    required this.producers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint boltPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 8.0;
    Paint linePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.0
          ..color = const Color.fromARGB(160, 158, 158, 158);
    for (PowerSink prod in producers) {
      for (PowerSink con in consumers) {
        Offset path = con.offset(size) - prod.offset(size);
        boltPaint.color = Color.lerp(prod.color(), con.color(), progress)!;

        final icon = Icons.bolt;

        final textPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 48.0,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: Color.lerp(prod.color(), con.color(), progress),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.drawLine(prod.offset(size), con.offset(size), linePaint);

        final position = prod.offset(size) + path * progress;
        final offset =
            position - Offset(textPainter.width / 2, textPainter.height / 2);
        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
