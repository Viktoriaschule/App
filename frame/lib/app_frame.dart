import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/app.dart';
import 'package:utils/utils.dart';

// ignore: public_member_api_docs
class AppFrame extends StatelessWidget {
  // ignore: public_member_api_docs
  const AppFrame({
    @required this.appName,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String appName;

  @override
  Widget build(BuildContext context) => EventBusWidget(
        child: Pages(
          child: ThemeWidget(
            child: App(
              appName: appName,
            ),
          ),
        ),
      );
}
