import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/utils/features.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'settings_localizations.dart';

/// SettingsPage class
/// describes the Settings widget
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends Interactor<SettingsPage> {
  int _design;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<TagsUpdateEvent>((event) => setState(_init));

  bool getNotifications(String key) =>
      Static.storage.getBool(Keys.notifications(key)) ?? true;

  void _init() {
    _design = Static.storage.getInt(Keys.design) ?? 0;
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
                title: SettingsLocalizations.notifications,
                children: notificationFeatures
                    .map(
                      (feature) => SwitchListTile(
                        title: Text(
                          feature.name,
                          style: TextStyle(
                            color: ThemeWidget.of(context).textColor,
                          ),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: getNotifications(feature.featureKey),
                        onChanged: (value) async {
                          setState(() {
                            Static.storage.setBool(
                                Keys.notifications(feature.featureKey), value);
                          });
                          try {
                            await Static.tags.syncDevice(
                              context,
                              FeaturesWidget
                                  .of(context)
                                  .features,
                            );
                            // ignore: empty_catches
                          } on DioError {}
                        },
                      ),
                    )
                    .toList(),
              ),
            ListGroup(
              title: SettingsLocalizations.design,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _design,
                    onChanged: (value) {
                      setState(() {
                        _design = value;
                      });
                      Static.storage.setInt(Keys.design, value);
                      EventBus.of(context).publish(ThemeChangedEvent());
                    },
                    items: const [
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text(SettingsLocalizations.automatic),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(SettingsLocalizations.light),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(SettingsLocalizations.dark),
                      ),
                    ],
                  ),
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
                    AppLocalizations.logout,
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
