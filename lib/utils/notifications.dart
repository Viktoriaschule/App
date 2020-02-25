import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/aixformation/aixformation_post.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_page.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_page.dart';
import 'package:viktoriaapp/timetable/timetable_page.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/static.dart';

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
  /// Register everything needed for notifications
  Future _registerNotifications(BuildContext context) async {
    if (Platform().isMobile || Platform().isWeb) {
      Static.firebaseMessaging.configure(
        onLaunch: (data) async {
          print('onLaunch: $data');
          await _backgroundNotification(context, data);
        },
        onResume: (data) async {
          print('onResume: $data');
          await _backgroundNotification(context, data);
        },
        onMessage: (data) async {
          print('onMessage: $data');
          await _foregroundNotification(context, data);
        },
      );
    }
    if (Platform().isAndroid) {
      await MethodChannel('app.viktoria.schule')
          .invokeMethod('channel_registered');
    }
  }

  Future _foregroundNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    if (data['action'] != 'update') {
      return;
    }
    VoidCallback callback;
    String text;
    switch (data[Keys.type]) {
      case Keys.substitutionPlanNotification:
        callback = () => _openSubstitutionPlan(int.parse(data['day']));
        text = 'Neuer Vertretungsplan';
        break;
      case Keys.timetable:
        callback = _openTimetable;
        text = 'Neuer Stundenplan';
        break;
      case Keys.cafetoria:
        callback = _openCafetoria;
        text = 'Neue Cafetoria-Menüs';
        break;
      case Keys.aiXformation:
        // ignore: missing_required_param
        callback = () => _openAiXformation(Post(url: data['url']));
        text = 'Neuer AiXformation-Artikel';
        break;
      default:
        print('Got unknown notification: $data');
        return;
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      action: SnackBarAction(
        label: 'Öffnen',
        onPressed: () async {
          EventBus.of(context).publish(FetchAppDataEvent());
          callback();
        },
      ),
      content: Text(text),
    ));
  }

  Future _backgroundNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    switch (data['type']) {
      case Keys.substitutionPlanNotification:
        EventBus.of(context).publish(FetchAppDataEvent());
        _openSubstitutionPlan(int.parse(data['day']));
        break;
      case Keys.timetable:
        EventBus.of(context).publish(FetchAppDataEvent());
        _openTimetable();
        break;
      case Keys.cafetoria:
        EventBus.of(context).publish(FetchAppDataEvent());
        _openCafetoria();
        break;
      case Keys.aiXformation:
        EventBus.of(context).publish(FetchAppDataEvent());
        // ignore: missing_required_param
        _openAiXformation(Post(url: data['url']));
        break;
      default:
        print('Got unknown notification: $data');
        break;
    }
  }

  void _openTimetable() =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(TimetablePage()));

  void _openSubstitutionPlan(int day) => EventBus.of(context)
          .publish(PushMaterialPageRouteEvent(SubstitutionPlanPage(
        day: day,
      )));

  void _openCafetoria() =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(CafetoriaPage()));

  void _openAiXformation(Post post) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(AiXformationPost(
        post: post,
        posts: Static.aiXformation.hasLoadedData
            ? Static.aiXformation.data.posts
            : [],
      )));

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void afterFirstLayout(BuildContext context) =>
      _registerNotifications(context);
}
