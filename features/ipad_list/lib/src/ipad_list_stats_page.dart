import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ipad_list/ipad_list.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_keys.dart';
import 'ipad_list_loader.dart';
import 'ipad_list_localizations.dart';
import 'ipad_list_model.dart';

/// A page for ipad statistics like battery history
class IPadListStatsPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const IPadListStatsPage({
    @required this.iPads,
    @required this.groupName,
    Key key,
  }) : super(key: key);

  /// All iPads for the statistics
  final List<IPad> iPads;

  /// The name of the given iPad list
  final String groupName;

  @override
  _IPadListStatsPageState createState() => _IPadListStatsPageState();
}

class _IPadListStatsPageState extends State<IPadListStatsPage> {
  DeviceHistory data;
  _Timespan loadedTimespan;
  DateTime loadedDate;

  Future loadData(BuildContext context, IPadListLoader loader, DateTime date,
      {bool offline = false}) async {
    if (data == null && !offline) {
      await loadData(context, loader, date, offline: true);
    }
    final _data = await loader.deviceHistoryLoader
        .getDeviceHistory(context, widget.iPads, date, loadOffline: offline);
    loadedDate = date;
    if (mounted) {
      setState(() => data = _data);
    }
  }

  BaseChart getBatteryHistoryChart() {
    final chartData = widget.iPads
        .map((iPad) => Series<HistoryEntry, DateTime>(
              id: iPad.name,
              displayName: iPad.name,
              domainFn: (entry, _) => entry.lastModified,
              measureFn: (entry, _) => entry.level / 100,
              data: [
                if (data.entries[iPad.id].isNotEmpty)
                  ...data.entries[iPad.id]
                else
                  HistoryEntry(
                    id: iPad.id,
                    level: iPad.batteryLevel,
                    lastModified: loadedDate,
                  ),
                HistoryEntry(
                  id: iPad.id,
                  level: iPad.batteryLevel,
                  lastModified: DateTime.now(),
                ),
              ],
            ))
        .toList();
    return TimeSeriesChart(
      chartData,
      animate: true,
      primaryMeasureAxis: PercentAxisSpec(
        renderSpec: SmallTickRendererSpec(
          labelStyle: TextStyleSpec(
            color: ThemeWidget.of(context).brightness == Brightness.dark
                ? MaterialPalette.white
                : MaterialPalette.black,
          ),
        ),
      ),
      domainAxis: DateTimeAxisSpec(
        renderSpec: SmallTickRendererSpec(
          labelStyle: TextStyleSpec(
            color: ThemeWidget.of(context).brightness == Brightness.dark
                ? MaterialPalette.white
                : MaterialPalette.black,
          ),
        ),
      ),
    );
  }

  BaseChart getUpdateTimeChart() {
    final hours = <int>[];
    for (int i = 0; i < 24; i++) {
      hours.add(0);
    }

    // Count all updates per hour
    data.entries.forEach((id, entries) {
      for (final entry in entries) {
        hours[entry.lastModified.hour]++;
      }
    });

    final chartData = [
      Series<int, String>(
        id: IPadListLocalizations.statsUpdateTime,
        displayName: IPadListLocalizations.statsUpdateTime,
        measureFn: (count, _) => count,
        domainFn: (_, index) => index.toString(),
        data: hours,
      )
    ];

    return BarChart(
      chartData,
      animate: true,
      primaryMeasureAxis: AxisSpec<num>(
        renderSpec: SmallTickRendererSpec(
          labelStyle: TextStyleSpec(
            color: ThemeWidget.of(context).brightness == Brightness.dark
                ? MaterialPalette.white
                : MaterialPalette.black,
          ),
        ),
      ),
      domainAxis: AxisSpec<String>(
        tickProviderSpec: BasicOrdinalTickProviderSpec(),
        renderSpec: SmallTickRendererSpec(
          labelStyle: TextStyleSpec(
            color: ThemeWidget.of(context).brightness == Brightness.dark
                ? MaterialPalette.white
                : MaterialPalette.black,
          ),
        ),
      ),
    );
  }

  DateTime getOldestDate(_Timespan timespan) {
    Duration duration;

    switch (timespan) {
      case _Timespan.day:
        duration = Duration(hours: 24);
        break;
      case _Timespan.week:
        duration = Duration(days: 7);
        break;
      case _Timespan.month:
        duration = Duration(days: 30);
        break;
    }

    return DateTime.now().subtract(duration);
  }

  @override
  Widget build(BuildContext context) {
    final chartType =
        _ChartType.values[Static.storage.getInt(IPadListKeys.chartType) ?? 0];
    final loader = IPadListWidget.of(context).feature.loader;
    final timespan = _Timespan
        .values[Static.storage.getInt(IPadListKeys.chartTimespan) ?? 1];
    final oldestDate = getOldestDate(timespan);

    if (data == null || timespan != loadedTimespan) {
      loadedTimespan = timespan;
      loadData(context, loader, oldestDate);
    }

    Widget chart = Container();
    if (data != null) {
      switch (chartType) {
        case _ChartType.batteryHistory:
          chart = getBatteryHistoryChart();
          break;
        case _ChartType.updateTime:
          chart = getUpdateTimeChart();
          break;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '${IPadListLocalizations.stats} - ${widget.groupName}',
        sliver: false,
        loadingKeys: const [
          IPadListKeys.iPadList,
          IPadListKeys.iPadHistoryEntries
        ],
      ),
      body: CustomRefreshIndicator(
        loadOnline: () => loader.loadOnline(context, force: true),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: DropdownButton<_ChartType>(
                          isExpanded: true,
                          value: chartType,
                          onChanged: (chartType) {
                            setState(() {
                              Static.storage.setInt(
                                IPadListKeys.chartType,
                                chartType.index,
                              );
                            });
                          },
                          items: _ChartType.values
                              .map((charType) => DropdownMenuItem<_ChartType>(
                                    value: charType,
                                    child: Text(charType.displayName),
                                  ))
                              .toList()),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: DropdownButton<_Timespan>(
                        isExpanded: true,
                        value: timespan,
                        onChanged: (timespan) {
                          setState(() {
                            Static.storage.setInt(
                              IPadListKeys.chartTimespan,
                              timespan.index,
                            );
                          });
                        },
                        items: _Timespan.values
                            .map((timespan) => DropdownMenuItem<_Timespan>(
                                  value: timespan,
                                  child: Text(timespan.displayName),
                                ))
                            .toList()),
                  ),
                ],
              ),
            ),
            Container(
              height: 500,
              padding: EdgeInsets.all(20),
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ChartType {
  /// A chart for the battery history
  batteryHistory,

  /// A chart to analyse the battery update times
  updateTime,
}

const _displayNames = [
  IPadListLocalizations.statsBattery,
  IPadListLocalizations.statsUpdateTime
];

extension on _ChartType {
  String get displayName => _displayNames[index];
}

enum _Timespan { day, week, month }

const _displayNamesTimespan = [
  IPadListLocalizations.day,
  IPadListLocalizations.week,
  IPadListLocalizations.month
];

extension on _Timespan {
  String get displayName => _displayNamesTimespan[index];
}
