import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_button.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';

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
        Static.storage.getBool(Keys.substitutionPlanNotifications) ?? true;
    _aiXformationNotifications =
        Static.storage.getBool(Keys.aiXformationNotifications) ?? true;
    _cafetoriaNotifications =
        Static.storage.getBool(Keys.cafetoriaNotifications) ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: Pages.of(context).pages[Keys.settings].title,
          pageKey: Keys.settings,
        ),
        body: Material(
          child: Center(
            child: SizeLimit(
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5),
                  children: [
                    ListGroup(
                      title: 'Benachrichtigungen',
                      children: [
                        CheckboxListTile(
                          title: Text(
                            'Vertretungsplan',
                            style: TextStyle(
                              color: textColor(context),
                            ),
                          ),
                          checkColor: lightColor,
                          activeColor: Theme.of(context).accentColor,
                          value: _substitutionPlanNotifications,
                          onChanged: (value) async {
                            setState(() {
                              _substitutionPlanNotifications = value;
                              Static.storage.setBool(
                                  Keys.substitutionPlanNotifications, value);
                            });
                            try {
                              await Static.tags.syncDevice(context);
                              // ignore: empty_catches
                            } on DioError {}
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'AiXformation',
                            style: TextStyle(
                              color: textColor(context),
                            ),
                          ),
                          checkColor: lightColor,
                          activeColor: Theme.of(context).accentColor,
                          value: _aiXformationNotifications,
                          onChanged: (value) async {
                            setState(() {
                              _aiXformationNotifications = value;
                              Static.storage.setBool(
                                  Keys.aiXformationNotifications, value);
                            });
                            try {
                              await Static.tags.syncDevice(context);
                              // ignore: empty_catches
                            } on DioError {}
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Cafétoria',
                            style: TextStyle(
                              color: textColor(context),
                            ),
                          ),
                          checkColor: lightColor,
                          activeColor: Theme.of(context).accentColor,
                          value: _cafetoriaNotifications,
                          onChanged: (value) async {
                            setState(() {
                              _cafetoriaNotifications = value;
                              Static.storage
                                  .setBool(Keys.cafetoriaNotifications, value);
                            });
                            try {
                              await Static.tags.syncDevice(context);
                              // ignore: empty_catches
                            } on DioError {}
                          },
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, left: 5, right: 5),
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () {
                            Static.user.clear();
                            Static.updates.clear();
                            Static.substitutionPlan.clear();
                            Static.timetable.clear();
                            Static.calendar.clear();
                            Static.aiXformation.clear();
                            Static.cafetoria.clear();
                            Static.subjects.clear();
                            Static.storage
                                .getKeys()
                                .forEach(Static.storage.remove);
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                          child: Text(
                            'Abmelden',
                            style: TextStyle(
                              color: darkColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
