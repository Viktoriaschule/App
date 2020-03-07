import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/utils/features.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

/// SettingsPage class
/// describes the Settings widget
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends Interactor<SettingsPage> {
  bool _automaticDesign;
  bool _darkMode;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<TagsUpdateEvent>((event) => setState(_init));

  bool getNotifications(String key) =>
      Static.storage.getBool(Keys.notifications(key)) ?? true;

  void _init() {
    _automaticDesign = Static.storage.getBool(Keys.automaticDesign) ?? true;
    _darkMode = Static.storage.getBool(Keys.darkMode) ?? false;
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notificationFeatures = FeaturesWidget.of(context)
        .features
        .where((f) => f.notificationsHandler != null)
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        title: Pages.of(context).pages[Keys.settings].title,
        loadingKeys: [Keys.tags],
      ),
      body: Scrollbar(
        child: ListView(
          shrinkWrap: false,
          padding: EdgeInsets.all(5),
          children: [
            if (notificationFeatures.isNotEmpty)
              ListGroup(
                title: 'Benachrichtigungen',
                children: notificationFeatures
                    .map(
                      (feature) => CheckboxListTile(
                        title: Text(
                          feature.name,
                          style: TextStyle(
                            color: ThemeWidget.of(context).textColor,
                          ),
                        ),
                        checkColor: lightColor,
                        activeColor: Theme.of(context).accentColor,
                        value: getNotifications(feature.featureKey),
                        onChanged: (value) async {
                          setState(() {
                            Static.storage.setBool(
                                Keys.notifications(feature.featureKey), value);
                          });
                          try {
                            await Static.tags.syncDevice(context);
                            // ignore: empty_catches
                          } on DioError {}
                        },
                      ),
                    )
                    .toList(),
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
                      Static.storage.setBool(Keys.automaticDesign, value);
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
                            Static.storage.setBool(Keys.darkMode, value);
                            EventBus.of(context).publish(ThemeChangedEvent());
                          });
                        }
                      : null,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5, left: 10, right: 10),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    Static.user.clear();
                    Static.tags.clear();
                    Static.updates.clear();
                    // Clear the data of all features
                    FeaturesWidget.of(context)
                        .features
                        .where((f) => f.loader != null)
                        .forEach((f) => f.loader.clear());
                    Static.subjects.clear();
                    Static.storage.getKeys().forEach(Static.storage.remove);
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
    );
  }
}
