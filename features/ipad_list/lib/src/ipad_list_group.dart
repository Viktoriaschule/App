import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ipad_list/src/ipad_list_localizations.dart';
import 'package:ipad_list/src/ipad_list_page.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_model.dart';

// ignore: public_member_api_docs
class IPadGroupRow extends PreferredSize {
  // ignore: public_member_api_docs
  const IPadGroupRow({
    @required this.groupID,
    @required this.iPads,
    this.backgroundColor,
  });

  // ignore: public_member_api_docs
  final int groupID;

  // ignore: public_member_api_docs
  final List<IPad> iPads;

  /// The background color for the icon
  final Color backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) {
    final levels = iPads.map((iPad) => iPad.batteryLevel);
    final highestLevel = levels.reduce(max);
    final lowestLevel = levels.reduce(min);
    final level = levels.reduce((i1, i2) => i1 + i2) ~/ iPads.length;
    final groupName = groupID != 0
        ? groupID.toString().padLeft(2, '0')
        : IPadListLocalizations.teacher;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => IPadListPage(
              devices: Devices(iPads: iPads),
              groupName: '${IPadListLocalizations.iPadGroup}: $groupName',
            ),
          ),
        );
      },
      child: CustomRow(
        leading: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 0,
              child: Icon(
                Icons.tablet_mac,
                color: ThemeWidget.of(context).textColorLight.withAlpha(150),
              ),
            ),
            // Background color for the icon in the foreground
            Positioned(
              left: 7,
              top: 7,
              child: Container(
                width: 17,
                height: 21,
                color: backgroundColor ?? Theme.of(context).backgroundColor,
              ),
            ),
            Positioned(
              left: 5,
              top: 5,
              child: Container(
                child: Icon(
                  Icons.tablet_mac,
                  color: ThemeWidget.of(context).textColorLight,
                ),
              ),
            ),
          ],
        ),
        title: '${IPadListLocalizations.iPadGroup}: $groupName',
        titleOverflow: TextOverflow.ellipsis,
        subtitle: Row(
          children: <Widget>[
            Text(
              '~$level%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w100,
                color: ThemeWidget.of(context).textColor,
              ),
            ),
            BatteryIndicator(
              level: highestLevel,
              isCharging: false,
              showText: false,
            ),
            BatteryIndicator(
              level: lowestLevel,
              isCharging: false,
              showText: false,
            ),
          ],
        ),
        last: Text('+${iPads.length}'),
      ),
    );
  }
}
