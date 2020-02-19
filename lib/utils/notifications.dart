import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:viktoriaapp/aixformation/aixformation_post.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_page.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class NotificationsWidget extends StatefulWidget {
  // ignore: public_member_api_docs
  const NotificationsWidget({
    @required this.fetchData,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final FutureCallback fetchData;

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget>
    with AfterLayoutMixin<NotificationsWidget> {
  DateTime _lastSnackbar;

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
    await Static.tags.syncDevice();
    if (Platform().isAndroid) {
      await MethodChannel('app.viktoria.schule')
          .invokeMethod('channel_registered');
    }
  }

  Future _foregroundNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    FutureCallback callback;
    String text;
    switch (data[Keys.type]) {
      case Keys.substitutionPlanNotification:
        callback = _openSubstitutionPlan;
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
        callback = () async => _openAiXformation(Post(url: data['url']));
        text = 'Neuer AiXformation-Artikel';
        break;
    }
    if (_lastSnackbar == null ||
        DateTime.now().difference(_lastSnackbar).inSeconds > 3) {
      Scaffold.of(context).showSnackBar(SnackBar(
        action: SnackBarAction(
          label: 'Öffnen',
          onPressed: () async {
            await widget.fetchData();
            await callback();
          },
        ),
        content: Text(
          text,
          style: TextStyle(
            color: lightColor,
          ),
        ),
      ));
      _lastSnackbar = DateTime.now();
    }
  }

  Future _backgroundNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    switch (data['type']) {
      case Keys.substitutionPlanNotification:
        await widget.fetchData();
        await _openSubstitutionPlan();
        break;
      case Keys.timetable:
        await widget.fetchData();
        await _openTimetable();
        break;
      case Keys.cafetoria:
        await widget.fetchData();
        await _openCafetoria();
        break;
      case Keys.aiXformation:
        await widget.fetchData();
        // ignore: missing_required_param
        await _openAiXformation(Post(url: data['url']));
        break;
      default:
        print('Unknown key: ${data[Keys.type]}');
        break;
    }
  }

  //TODO: Change all open functions to new view
  Future _openTimetable() =>
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppPage(
          page: 1,
          loading: false,
        ),
      ));

  Future _openSubstitutionPlan() =>
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppPage(
          page: 0,
          loading: false,
        ),
      ));

  Future _openCafetoria() => Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CafetoriaPage(),
      ));

  Future _openAiXformation(Post post) =>
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AiXformationPost(
          post: post,
        ),
      ));

  @override
  Widget build(BuildContext context) => Container();

  @override
  void afterFirstLayout(BuildContext context) =>
      _registerNotifications(context);
}
