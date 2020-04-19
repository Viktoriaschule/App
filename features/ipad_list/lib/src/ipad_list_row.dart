import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_model.dart';

// ignore: public_member_api_docs
class IPadRow extends PreferredSize {
  // ignore: public_member_api_docs
  const IPadRow({
    @required this.iPad,
  });

  // ignore: public_member_api_docs
  final IPad iPad;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) => CustomRow(
        leading: Container(
          margin: EdgeInsets.only(top: 10),
          child: Icon(
            Icons.tablet_mac,
            color: ThemeWidget.of(context).textColorLight,
          ),
        ),
        title: iPad.name,
        titleOverflow: TextOverflow.ellipsis,
        subtitle: BatteryIndicator(
          level: iPad.batteryLevel,
          isCharging: iPad.isCharging,
        ),
        last: Container(),
      );
}
