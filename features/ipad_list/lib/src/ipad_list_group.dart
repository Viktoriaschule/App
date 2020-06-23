import 'dart:math';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_localizations.dart';
import 'ipad_list_model.dart';
import 'ipad_list_page.dart';

// ignore: public_member_api_docs
class IPadGroupRow extends PreferredSize {
  // ignore: public_member_api_docs
  const IPadGroupRow(
      {@required this.sortMethod,
      @required this.iPads,
      this.backgroundColor,
      this.disabledSortMethods = const []});

  // ignore: public_member_api_docs
  final SortMethod sortMethod;

  // ignore: public_member_api_docs
  final List<IPad> iPads;

  /// The background color for the icon
  final Color backgroundColor;

  /// All the disabled sort methods
  ///
  /// Methods are disabled to prevent sorting by the same properties multiple times
  final List<SortMethod> disabledSortMethods;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  /// Returns the group name for a list of grouped iPads
  String _getGroupName() {
    final iPad = iPads.isNotEmpty ? iPads.first : null;
    switch (sortMethod) {
      case SortMethod.groupID:
        final groupId = iPad?.groupID ?? -1;
        return groupId == 0
            ? IPadListLocalizations.teacher
            : groupId.toString().padLeft(2, '0');
      case SortMethod.isCharging:
        return (iPad?.isCharging ?? true)
            ? IPadListLocalizations.isCharging
            : IPadListLocalizations.isNotCharging;
      case SortMethod.deviceType:
        return (iPad?.deviceType ?? DeviceType.student) == DeviceType.teacher
            ? IPadListLocalizations.teacher
            : IPadListLocalizations.student;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = iPads.map((iPad) => iPad.batteryLevel);
    final highestLevel = levels.reduce(max);
    final lowestLevel = levels.reduce(min);
    final level = levels.reduce((i1, i2) => i1 + i2) ~/ iPads.length;
    final groupName = _getGroupName();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => IPadListPage(
              devices: Devices(iPads: [...iPads]),
              groupName: '${IPadListLocalizations.iPadGroup}: $groupName',
              disabledSortMethods: [...disabledSortMethods, sortMethod],
            ),
          ),
        );
      },
      child: CustomRow(
        leading: Stack(
          children: [
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
        title: Text(
          '${IPadListLocalizations.iPadGroup}: $groupName',
          style: TextStyle(
            fontSize: 17,
            color: Theme.of(context).accentColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
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
