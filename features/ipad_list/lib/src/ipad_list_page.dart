import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:ipad_list/ipad_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_events.dart';
import 'ipad_list_group.dart';
import 'ipad_list_keys.dart';
import 'ipad_list_localizations.dart';
import 'ipad_list_model.dart';
import 'ipad_list_row.dart';
import 'ipad_list_stats_page.dart';

// ignore: public_member_api_docs
class IPadListPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const IPadListPage(
      {this.devices, this.groupName, this.disabledSortMethods, Key key})
      : super(key: key);

  /// An optional selection of devices
  ///
  /// If empty, all devices will be shown
  final Devices devices;

  /// The title for the device list
  final String groupName;

  /// If the sorted by groups method is enabled
  final List<SortMethod> disabledSortMethods;

  @override
  _IPadListPageState createState() => _IPadListPageState();
}

class _IPadListPageState extends Interactor<IPadListPage>
    with TickerProviderStateMixin {
  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<IPadListUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    // Store the sort method for each page int the correct context
    final keyPrefix = widget.groupName != null
        ? '${widget.disabledSortMethods?.join('-') ?? ''}-${widget.groupName}-'
        : '';
    final sortIndex =
        Static.storage.getInt(keyPrefix + IPadListKeys.iPadSortMethod) ??
            (widget.groupName == null ? 5 : 1);
    final sortDirection = sortIndex > 0;
    final sortMethod = SortMethod.values[sortIndex.abs() - 1];
    final loader = IPadListWidget.of(context).feature.loader;

    List<List<IPad>> groups = [];
    List<IPad> devices = [];
    Devices _devices;
    if (widget.devices == null || widget.devices.iPads.isEmpty) {
      _devices = loader.data;
    } else {
      _devices = widget.devices ?? Devices(iPads: []);
    }

    if (sortMethod.isGrouped) {
      groups = _devices.getGroupedList(sortMethod);
    } else {
      devices = _devices.getSortedList(sortMethod);
    }

    final count = (sortMethod.isGrouped ? groups : devices).length;

    if (!sortDirection) {
      groups = groups.reversed.toList();
      devices = devices.reversed.toList();
    }
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        CustomAppBar(
          title: widget.groupName ?? IPadListLocalizations.name,
          sliver: true,
          actions: [
            if (devices.isNotEmpty)
              IconButton(
                icon: Icon(MdiIcons.chartLine),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => IPadListStatsPage(
                        groupName: widget.groupName != null
                            ? widget.groupName.split(' ')[1]
                            : IPadListLocalizations.all,
                        iPads: devices,
                      ),
                    ),
                  );
                },
              )
          ],
          loadingKeys: const [
            IPadListKeys.iPadList,
            IPadListKeys.iPadHistoryEntries
          ],
        ),
      ],
      body: CustomRefreshIndicator(
        loadOnline: () => loader.loadOnline(context, force: true),
        child: count > 0
            ? Scrollbar(
                child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 10),
                    itemCount: count + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 70,
                              child: Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: sortMethod.index,
                                    onChanged: (index) {
                                      Static.storage.setInt(
                                          keyPrefix +
                                              IPadListKeys.iPadSortMethod,
                                          index + 1);
                                      EventBus.of(context)
                                          .publish(IPadListUpdateEvent());
                                    },
                                    items: SortMethod.values
                                        .where((element) =>
                                            widget.disabledSortMethods ==
                                                null ||
                                            !widget.disabledSortMethods
                                                .contains(element))
                                        .map((method) => DropdownMenuItem<int>(
                                              value: method.index,
                                              child: Text(method.displayName),
                                            ))
                                        .toList()),
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () {
                                    Static.storage.setInt(
                                      keyPrefix + IPadListKeys.iPadSortMethod,
                                      -sortIndex,
                                    );
                                    EventBus.of(context)
                                        .publish(IPadListUpdateEvent());
                                  },
                                  icon: Icon(
                                    sortDirection
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      if (sortMethod.isGrouped) {}
                      return SizeLimit(
                        child: !sortMethod.isGrouped
                            ? IPadRow(iPad: devices[index - 1])
                            : IPadGroupRow(
                                sortMethod: sortMethod,
                                iPads: groups[index - 1],
                                disabledSortMethods:
                                    widget.disabledSortMethods ?? [],
                              ),
                      );
                    }),
              )
            : EmptyList(title: IPadListLocalizations.noIPads),
      ),
    );
  }
}
