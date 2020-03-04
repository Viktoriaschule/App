import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/app.dart';
import 'package:utils/utils.dart';
import 'package:frame/utils/features.dart';

// ignore: public_member_api_docs
class AppFrame extends StatelessWidget {
  // ignore: public_member_api_docs
  const AppFrame({
    @required this.appName,
    @required this.features,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String appName;

  /// All features in the app
  final List<Feature> features;

  @override
  Widget build(BuildContext context) => EventBusWidget(
        child: Features(
          features: features,
          child: Pages(
            child: ThemeWidget(
              child: App(
                appName: appName,
              ),
            ),
          ),
        ),
      );
}
