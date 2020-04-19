import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';

const List<IconData> _chargingStates = [
  MdiIcons.battery10,
  MdiIcons.battery20,
  MdiIcons.battery30,
  MdiIcons.battery40,
  MdiIcons.battery50,
  MdiIcons.battery60,
  MdiIcons.battery70,
  MdiIcons.battery80,
  MdiIcons.battery90,
  MdiIcons.battery,
  MdiIcons.batteryCharging10,
  MdiIcons.batteryCharging20,
  MdiIcons.batteryCharging30,
  MdiIcons.batteryCharging40,
  MdiIcons.batteryCharging50,
  MdiIcons.batteryCharging60,
  MdiIcons.batteryCharging70,
  MdiIcons.batteryCharging80,
  MdiIcons.batteryCharging90,
  MdiIcons.batteryCharging,
];

/// A battery indicator
class BatteryIndicator extends StatelessWidget {
  // ignore: public_member_api_docs
  const BatteryIndicator(
      {Key key, this.isCharging, this.level, this.showText = true})
      : super(key: key);

  /// Whether the battery is currently charging or not
  final bool isCharging;

  /// The battery level in percent (0 to 100)
  final int level;

  /// If the percent text should be shown
  final bool showText;

  @override
  Widget build(BuildContext context) {
    int level = this.level;
    if (level == 100) {
      level--;
    }
    final iconIndex = level ~/ 10 + (isCharging ? 10 : 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showText)
          Text(
            '$level%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w100,
              color: ThemeWidget.of(context).textColor,
            ),
          ),
        Icon(
          _chargingStates[iconIndex],
          size: 14,
          color: ThemeWidget.of(context).textColorLight,
        ),
      ],
    );
  }
}
