import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/utils/features.dart';
import 'package:utils/utils.dart';

// ignore: public_member_api_docs
class NotificationsWidget extends StatefulWidget {
  // ignore: public_member_api_docs
  const NotificationsWidget({
    @required this.child,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Widget child;

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget>
    with AfterLayoutMixin<NotificationsWidget> {
  static MethodChannel methodChannel = MethodChannel('frame');

  NotificationsHandler _getNotificationHandler(
      BuildContext context, String type) {
    final features = FeaturesWidget.of(context)
        .features
        .where((f) => f.featureKey == type)
        .toList();
    if (features.isNotEmpty && features.first.notificationsHandler != null) {
      return features.first.notificationsHandler;
    }
    print('There is no notification handler for a \'$type\' notification');
    return null;
  }

  /// Register everything needed for notifications
  Future _registerNotifications(BuildContext context) async {
    if (Platform().isMobile || Platform().isWeb) {
      Static.firebaseMessaging.configure(
        onLaunch: handleOnLaunchResumeNotification,
        onResume: handleOnLaunchResumeNotification,
        onMessage: handleOnMessageNotification,
        onBackgroundMessage:
            _NotificationsWidgetState.handleOnBackgroundMessageNotification,
      );
    }
    if (Platform().isAndroid) {
      await methodChannel.invokeMethod('init');
    }
  }

  Future handleOnLaunchResumeNotification(
    Map<String, dynamic> data,
  ) async {
    EventBus.of(context).publish(FetchAppDataEvent());
    final handler = _getNotificationHandler(context, data['type']);
    if (handler != null) {
      handler.open(data, context);
    }
  }

  Future<dynamic> handleOnMessageNotification(
    Map<String, dynamic> d,
  ) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(d['data']);
      if (data['action'] != 'update') {
        return;
      }
      final handler = _getNotificationHandler(context, d['type']);
      if (handler != null) {
        EventBus.of(context).publish(FetchAppDataEvent());
        Scaffold.of(context).showSnackBar(SnackBar(
          action: SnackBarAction(
            label: 'Öffnen',
            onPressed: () => handler.open(d, context),
          ),
          content: Text(handler.getSnackBarText(d, context)),
        ));
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
    return;
  }

  // This needs to be a static function otherwise it can't be called
  static Future<dynamic> handleOnBackgroundMessageNotification(
    Map<String, dynamic> d,
  ) async {
    final Map<String, dynamic> data = d['data'].cast<String, dynamic>();
    try {
      if (data['action'] == 'update') {
        return;
      }
      if (Platform().isAndroid) {
        //TODO: Set the group on the server, because in a static function without context, the function cannot call any feature
        final Map<String, int> groups = {
          'substitution plan':
              data['weekday'] != null ? int.parse(data['weekday']) : 0,
          'cafetoria': 5,
          'aixformation': 6,
          'timetable': 7,
        };
        await methodChannel.invokeMethod(
          'notification',
          {
            ...data,
            'group': groups[data['type']],
          },
        );
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
    return;
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void afterFirstLayout(BuildContext context) =>
      _registerNotifications(context);
}
