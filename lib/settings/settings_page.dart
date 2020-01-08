import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/models/models.dart';

/// SettingsPage class
/// describes the Settings widget
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _substitutionPlanNotifications;
  bool _aiXformationNotifications;
  bool _cafetoriaNotifications;

  @override
  void initState() {
    _substitutionPlanNotifications =
        Static.storage.getBool(Keys.substitutionPlanNotifications) || true;
    _aiXformationNotifications =
        Static.storage.getBool(Keys.aiXformationNotifications) || true;
    _cafetoriaNotifications =
        Static.storage.getBool(Keys.cafetoriaNotifications) || true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Einstellungen'),
        ),
        body: Center(
          child: SizeLimit(
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(5),
                children: [
                  CheckboxListTile(
                    title: Text('Vertretungsplanbenachrichtigungen anzeigen'),
                    value: _substitutionPlanNotifications,
                    onChanged: (value) async {
                      setState(() {
                        _substitutionPlanNotifications = value;
                        Static.storage
                            .setBool(Keys.substitutionPlanNotifications, value);
                      });
                      try {
                        await Static.tags.syncDevice();
                        // ignore: empty_catches
                      } on DioError {}
                    },
                  ),
                  CheckboxListTile(
                    title: Text('AiXformation-Benachrichtigungen anzeigen'),
                    value: _aiXformationNotifications,
                    onChanged: (value) async {
                      setState(() {
                        _aiXformationNotifications = value;
                        Static.storage
                            .setBool(Keys.aiXformationNotifications, value);
                      });
                      try {
                        await Static.tags.syncDevice();
                        // ignore: empty_catches
                      } on DioError {}
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Cafétoria-Benachrichtigungen anzeigen'),
                    value: _cafetoriaNotifications,
                    onChanged: (value) async {
                      setState(() {
                        _cafetoriaNotifications = value;
                        Static.storage
                            .setBool(Keys.cafetoriaNotifications, value);
                      });
                      try {
                        await Static.tags.syncDevice();
                        // ignore: empty_catches
                      } on DioError {}
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 5, right: 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          Static.user.clear();
                          Static.updates.clear();
                          Static.substitutionPlan.clear();
                          Static.timetable.clear();
                          Static.calendar.clear();
                          Static.aiXformation.clear();
                          Static.cafetoria.clear();
                          Static.subjects.clear();
                          Static.storage.getKeys().forEach(Static.storage.remove);
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        child: Text('Abmelden'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
