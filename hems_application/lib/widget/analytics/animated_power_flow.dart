import 'package:flutter/material.dart';
import 'package:hems_app/state/stat_collector.dart';
import 'package:hems_app/widget/analytics/power_flow_painter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AnimatedPowerFlow extends StatefulWidget {
  const AnimatedPowerFlow({super.key});

  @override
  State<StatefulWidget> createState() {
    return AnimatedPowerFlowState();
  }
}

class AnimatedPowerFlowState extends State<AnimatedPowerFlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _statCollector = StatCollector();

  /// Initializes the [AnimationController].
  ///
  /// The animation progressed by a value that cycles from 0.0 to 1.0, and doesn't go in the reverse direction when it reaches 1.0.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  /// Builds the widget
  ///
  /// Uses an [AnimatedBuilder] to get access to a value that ticks at the correct framerate.
  /// The tick value is used to animate the [CustomPainter] that creates lines and moving thunderbolts between devices.context
  /// Uses [StatCollector] to get access to the current consumers and producers in the home.
  /// The consumers and producers lists dictate where and in what direction the animation goes.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _statCollector,
      builder: (context, _) {
        return Align(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.width * 0.85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder:
                      (_, __) => CustomPaint(
                        painter: PowerFlowPainter(
                          progress: _animation.value,
                          consumers: _statCollector.consumers,
                          producers: _statCollector.producers,
                        ),
                        size: Size(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.width,
                        ),
                      ),
                ),
                Positioned(
                  right: 10,
                  child: Card(
                    child: Icon(
                      Icons.solar_power_rounded,
                      size: 60,
                      color: Colors.amber,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  child: Card(
                    child: Icon(Icons.battery_full, size: 60, color: Colors.green),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Card(
                    child: Icon(
                      MdiIcons.transmissionTower,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  child: Card(
                    child: Icon(Icons.home_rounded, size: 60, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Disposes the animation controller since otherwise it would keep ticking.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
