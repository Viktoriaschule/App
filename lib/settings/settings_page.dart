import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_button.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

/// SettingsPage class
/// describes the Settings widget
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends Interactor<SettingsPage> {
  bool _substitutionPlanNotifications;
  bool _aiXformationNotifications;
  bool _cafetoriaNotifications;
  bool _automaticDesign;
  bool _darkMode;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<TagsUpdateEvent>((event) => setState(_init));

  void _init() {
    _substitutionPlanNotifications =
        Static.storage.getBool(Keys.substitutionPlanNotifications) ?? true;
    _aiXformationNotifications =
        Static.storage.getBool(Keys.aiXformationNotifications) ?? true;
    _cafetoriaNotifications =
        Static.storage.getBool(Keys.cafetoriaNotifications) ?? true;
    _automaticDesign = Static.storage.getBool(Keys.automaticDesign) ?? true;
    _darkMode = Static.storage.getBool(Keys.darkMode) ?? false;
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: Pages.of(context).pages[Keys.settings].title,
          loadingKeys: [Keys.tags],
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
                              color: ThemeWidget.of(context).textColor,
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
                              color: ThemeWidget.of(context).textColor,
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
                              color: ThemeWidget.of(context).textColor,
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
                    ListGroup(
                      title: 'Design',
                      children: [
                        CheckboxListTile(
                          title: Text(
                            'Automatisch',
                            style: TextStyle(
                              color: ThemeWidget.of(context).textColor,
                            ),
                          ),
                          checkColor: lightColor,
                          activeColor: Theme.of(context).accentColor,
                          value: _automaticDesign,
                          onChanged: (value) async {
                            setState(() {
                              _automaticDesign = value;
                              Static.storage
                                  .setBool(Keys.automaticDesign, value);
                              EventBus.of(context).publish(ThemeChangedEvent());
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Dunkles Design',
                            style: TextStyle(
                              color: ThemeWidget.of(context).textColor,
                            ),
                          ),
                          checkColor: lightColor,
                          activeColor: Theme.of(context).accentColor,
                          value: _darkMode,
                          onChanged: !_automaticDesign
                              ? (value) async {
                                  setState(() {
                                    _darkMode = value;
                                    Static.storage
                                        .setBool(Keys.darkMode, value);
                                    EventBus.of(context)
                                        .publish(ThemeChangedEvent());
                                  });
                                }
                              : null,
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
                            Static.tags.clear();
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
                            EventBus.of(context).publish(ThemeChangedEvent());
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/${Keys.login}', (r) => false);
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
