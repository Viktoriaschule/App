import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ginko/aixformation/aixformation_page.dart';
import 'package:ginko/app/app_page.dart';
import 'package:ginko/cafetoria/cafetoria_page.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/models/models.dart';

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
      await MethodChannel('de.ginko').invokeMethod('channel_registered');
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
        callback = () async {
          await Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AppPage(
              page: 0,
              loading: false,
            ),
          ));
        };
        text = 'Neuer Vertretungsplan';
        break;
      case Keys.timetable:
        callback = () async {
          await Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AppPage(
              page: 2,
              loading: false,
            ),
          ));
        };
        text = 'Neuer Studenplan';
        break;
      case Keys.cafetoria:
        callback = () async {
          await Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CafetoriaPage(),
          ));
        };
        text = 'Neue Cafetoria-Menüs';
        break;
      case Keys.aiXformation:
        callback = () async {
          await Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AiXformationPage(),
          ));
        };
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
        content: Text(text),
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
        await Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AppPage(
            page: 0,
            loading: false,
          ),
        ));
        break;
      case Keys.cafetoria:
        await widget.fetchData();
        await Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CafetoriaPage(),
        ));
        break;
      case Keys.aiXformation:
        await widget.fetchData();
        await Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AiXformationPage(),
        ));
        break;
      case Keys.timetable:
        await widget.fetchData();
        await Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AppPage(
            page: 2,
            loading: false,
          ),
        ));
        break;
      default:
        print('Unknown key: ${data['type']}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Container();

  @override
  void afterFirstLayout(BuildContext context) =>
      _registerNotifications(context);
}
