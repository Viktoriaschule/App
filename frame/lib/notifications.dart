import 'package:after_layout/after_layout.dart';
import 'package:aixformation/aixformation.dart';
import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';
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
    final Map<String, VoidCallback> callbacks = {
      Keys.substitutionPlanNotification: () => _openSubstitutionPlan(
          data['day'] != null ? int.parse(data['day']) : 0),
      Keys.timetable: _openTimetable,
      Keys.cafetoria: _openCafetoria,
      // ignore: missing_required_param
      Keys.aiXformation: () => _openAiXformation(Post(url: data['url'])),
    };
    callbacks[data['type']]();
  }

  Future<dynamic> handleOnMessageNotification(
    Map<String, dynamic> d,
  ) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(d['data']);
      if (data['action'] != 'update') {
        return;
      }
      final Map<String, VoidCallback> callbacks = {
        Keys.substitutionPlanNotification: () => _openSubstitutionPlan(
            data['day'] != null ? int.parse(data['day']) : 0),
        Keys.timetable: _openTimetable,
        Keys.cafetoria: _openCafetoria,
        // ignore: missing_required_param
        Keys.aiXformation: () => _openAiXformation(Post(url: data['url'])),
      };
      final Map<String, String> texts = {
        Keys.substitutionPlanNotification:
            'Neuer Vertretungsplan${Static.substitutionPlan.hasLoadedData && Static.substitutionPlan.data.days.isNotEmpty ? ' für ${weekdays[Static.substitutionPlan.data.days[data['day'] != null ? int.parse(data['day']) : 0].date.weekday - 1]}' : ''}',
        Keys.timetable: 'Neuer Stundenplan',
        Keys.cafetoria: 'Neue Cafetoria-Menüs',
        Keys.aiXformation: 'Neuer AiXformation-Artikel',
      };
      EventBus.of(context).publish(FetchAppDataEvent());
      Scaffold.of(context).showSnackBar(SnackBar(
        action: SnackBarAction(
          label: 'Öffnen',
          onPressed: callbacks[data['type']],
        ),
        content: Text(texts[data['type']]),
      ));
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

  void _openTimetable() =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(
        TimetablePage(),
      ));

  void _openSubstitutionPlan(int day) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(
        SubstitutionPlanPage(
          day: day,
        ),
      ));

  void _openCafetoria() =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(
        CafetoriaPage(),
      ));

  // TODO: Only shows a screen with no content and not even the app bar
  void _openAiXformation(Post post) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(
        AiXformationPost(
          post: post,
          posts: Static.aiXformation.hasLoadedData
              ? Static.aiXformation.data.posts
              : [],
        ),
      ));

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void afterFirstLayout(BuildContext context) =>
      _registerNotifications(context);
}
