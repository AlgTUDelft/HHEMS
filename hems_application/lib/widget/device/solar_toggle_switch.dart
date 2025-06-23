import 'package:flutter/material.dart';
import 'package:hems_app/model/internal/device.dart';
import 'package:hems_app/service/solar_service.dart';
import 'package:hems_app/state/app_state.dart';

class SolarToggleSwitch extends StatelessWidget {
  final Device solarPanel;
  SolarToggleSwitch({required this.solarPanel, super.key});

  final _appState = AppState();
  final _solarService = SolarService();

  /// Builds the widget.
  ///
  /// When the switch is toggled, the state of the solar panels is updated to match.
  /// The switch only toggles visually if the backend responds with success on toggling the solar panel.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 4),
            Switch(
              value: _appState.isSolarEnabled,
              activeColor: Colors.green,
              onChanged: (bool newEnabled) async {
                final result = await _solarService.setState(0, 0, newEnabled);

                if (result.isLeft) {
                  _appState.isSolarEnabled = newEnabled;
                }
              },
            ),
          ],
        );
      },
    );
  }
}
