import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ipad_list/ipad_list.dart';
import 'package:ipad_list/src/ipad_list_loader.dart';
import 'package:ipad_list/src/ipad_list_localizations.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'ipad_list_keys.dart';
import 'ipad_list_model.dart';

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
  BatteryHistory data;

  Future loadData(BuildContext context, IPadListLoader loader) async {
    final _data = await loader.batteryHistoryLoader
        .getBatteryHistory(context, widget.iPads);
    if (mounted) {
      setState(() => data = _data);
    }
  }

  Widget getBatteryHistoryChart() {
    final chartData = data.entries.keys.map((id) {
      final iPad = widget.iPads.where((e) => e.id == id).single;
      return Series<BatteryEntry, DateTime>(
        id: iPad.name,
        displayName: iPad.name,
        domainFn: (entry, _) => entry.timestamp,
        measureFn: (entry, _) => entry.level / 100,
        data: data.entries[id],
      );
    }).toList();
    return TimeSeriesChart(
      chartData,
      animate: true,
      primaryMeasureAxis: PercentAxisSpec(
          renderSpec: SmallTickRendererSpec(
              labelStyle: TextStyleSpec(
        color: ThemeWidget.of(context).brightness == Brightness.dark
            ? MaterialPalette.white
            : MaterialPalette.black,
      ))),
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

  Widget getUpdateTimeChart() {
    final hours = <int>[];
    for (int i = 0; i < 24; i++) {
      hours.add(0);
    }

    // Count all updates per hour
    data.entries.forEach((id, entries) {
      for (final entry in entries) {
        hours[entry.timestamp.hour]++;
      }
    });

    final chartData = [
      Series<int, int>(
        id: IPadListLocalizations.statsUpdateTime,
        displayName: IPadListLocalizations.statsUpdateTime,
        measureFn: (count, _) => count,
        domainFn: (_, index) => index + 1,
        data: hours,
      )
    ];

    return LineChart(
      chartData,
      animate: true,
      primaryMeasureAxis: AxisSpec<num>(
          renderSpec: SmallTickRendererSpec(
              labelStyle: TextStyleSpec(
        color: ThemeWidget.of(context).brightness == Brightness.dark
            ? MaterialPalette.white
            : MaterialPalette.black,
      ))),
      domainAxis: AxisSpec<num>(
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final chartType =
        _ChartType.values[Static.storage.getInt(IPadListKeys.chartType) ?? 0];
    final loader = IPadListWidget.of(context).feature.loader;

    if (data == null) {
      loadData(context, loader);
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
          IPadListKeys.iPadBatteryEntries
        ],
      ),
      body: CustomRefreshIndicator(
        loadOnline: () => loader.loadOnline(context, force: true),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15, right: 15),
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
