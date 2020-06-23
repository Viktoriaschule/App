import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'features.dart';

// ignore: public_member_api_docs
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  DateTime _day;
  Future<void> _timeUpdates = Future.delayed(Duration(seconds: 0));
  List<Feature> _features;
  Subscription _subscription;
  EventBus _eventBus;

  DateTime _getDay(List<Feature> features, EventBus eventBus) {
    if (_subscription != null) {
      _subscription.dispose();
    }
    // Get the first feature that wants to set the home page day
    for (final feature in features) {
      final date = feature.getHomePageDate();
      if (date != null) {
        // Subscribe to data updates of the time relevant feature
        _subscription = feature.subscribeToDataUpdates(eventBus, (event) {
          _day = _getDay(features, eventBus);
          setState(() => null);
          _timeUpdate();
        });

        final newDay = DateTime(date.year, date.month, date.day);
        if (newDay != _day) {
          eventBus.publish(DateUpdateEvent(newDay));
        }
        return newDay;
      }
    }
    // If there is no feature to set the day, set the home page to today
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Cancel the time updater
  Future<void> _cancelTimeUpdate() async {
    try {
      // After updating the timeout the future will directly stops
      await _timeUpdates.timeout(Duration(seconds: 0));
      // Wait until the future is finished
      await _timeUpdates;
    } on TimeoutException {
      // An await throws a timeout when the future was finished after a timeout, so catch them
      return;
    }
  }

  /// Update the time automatically
  Future<void> _timeUpdate() async {
    // Get the closest duration
    Duration duration;
    for (final feature in _features) {
      final d = feature.durationToHomePageDateUpdate();
      if (d != null && (duration == null || duration.inSeconds > d.inSeconds)) {
        if (d.inSeconds < 0) {
          print('Error in ${feature.name} time update duration: $duration');
        } else {
          duration = d;
        }
      }
    }

    // Only set if there is a feature that wants to update after a specific time
    if (duration != null) {
      // First cancel the current updater
      await _cancelTimeUpdate();

      // Set the new updater
      _timeUpdates = Future.delayed(duration).then((_) {
        if (mounted) {
          setState(() {
            _day = _getDay(_features, _eventBus);
          });
          _timeUpdate();
        }
      });
    }
  }

  @override
  void dispose() {
    _cancelTimeUpdate();
    _subscription.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) => _timeUpdate();

  @override
  Widget build(BuildContext context) {
    //final size = getScreenSize(MediaQuery.of(context).size.width);
    // Get the date for the home page

    _features ??= FeaturesWidget.of(context).guiFeatures;
    _eventBus ??= EventBus.of(context);
    _day ??= _getDay(_features, _eventBus);

    final size = getScreenSize(MediaQuery.of(context).size.width);
    final numberColumns = size.index + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final numberRows = (_features.length / numberColumns).ceil();
        final height =
            numberColumns > 1 ? constraints.maxHeight / numberRows : null;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.only(top: 0),
            children: List.generate(
              numberRows,
              (rowIndex) => Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(numberColumns, (columnIndex) {
                    final index = rowIndex * numberColumns + columnIndex;
                    if (index >= _features.length) {
                      return Expanded(
                        child: Container(),
                      );
                    }
                    return Expanded(
                      child: _features[index].getInfoCard(_day, height),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
