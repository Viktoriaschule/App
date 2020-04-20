import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:ipad_list/ipad_list.dart';
import 'package:ipad_list/src/ipad_list_events.dart';
import 'package:ipad_list/src/ipad_list_localizations.dart';
import 'package:ipad_list/src/ipad_list_page.dart';
import 'package:ipad_list/src/ipad_list_row.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_group.dart';
import 'ipad_list_keys.dart';
import 'ipad_list_model.dart';

// ignore: public_member_api_docs
class IPadListInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const IPadListInfoCard({
    @required DateTime date,
    double maxHeight,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

  @override
  _IPadListInfoCardState createState() => _IPadListInfoCardState();
}

class _IPadListInfoCardState extends InfoCardState<IPadListInfoCard> {
  InfoCardUtils utils;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<IPadListUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup build(BuildContext context) {
    final sortIndex = Static.storage.getInt(IPadListKeys.iPadSortMethod) ?? 1;
    final sortDirection = sortIndex > 0;
    final sortMethod = SortMethod.values[sortIndex.abs() - 1];
    final loader = IPadListWidget.of(context).feature.loader;

    List<List<IPad>> groups = [];
    List<IPad> devices = [];
    if (loader.hasLoadedData && sortMethod.isGrouped) {
      groups = loader.data.getGroupedList(sortMethod);
    } else if (loader.hasLoadedData) {
      devices = loader.data.getSortedList(sortMethod);
    }

    if (!sortDirection) {
      groups = groups.reversed.toList();
      devices = devices.reversed.toList();
    }

    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery
          .of(context)
          .size
          .width),
      (sortMethod.isGrouped ? groups : devices).length,
    );
    return ListGroup(
      loadingKeys: const [
        IPadListKeys.iPadList,
        IPadListKeys.iPadBatteryEntries
      ],
      heroId: IPadListKeys.iPadList,
      title: IPadListLocalizations.name,
      counter: (sortMethod.isGrouped ? groups : devices).length - cut,
      maxHeight: widget.maxHeight,
      actions: [
        NavigationAction(
          Icons.expand_more,
              () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => IPadListPage()),
            );
          },
        ),
      ],
      children: [
        if (!loader.hasLoadedData ||
            (sortMethod.isGrouped ? groups.isEmpty : devices.isEmpty))
          EmptyList(title: IPadListLocalizations.noIPads)
        else
          if (!sortMethod.isGrouped)
            ...(devices.length > cut ? devices.sublist(0, cut) : devices)
                .map((iPad) => IPadRow(iPad: iPad))
                .toList()
                .cast<PreferredSize>()
          else
            ...(groups.length > cut ? groups.sublist(0, cut) : groups)
                .map((group) =>
                IPadGroupRow(
                  sortMethod: sortMethod,
                  iPads: group,
                  backgroundColor: Theme
                      .of(context)
                      .primaryColor,
                  ))
              .toList()
              .cast<PreferredSize>(),
      ],
    );
  }
}
