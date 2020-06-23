import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/features.dart';
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
  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<TagsUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    final notificationFeatures = FeaturesWidget.of(context)
        .features
        .where((f) => f.notificationsHandler != null)
        .toList();
    final regularFeatures = FeaturesWidget.of(context)
        .features
        .where((f) => f.extraSettings != null)
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        title: SettingsLocalizations.settings,
        loadingKeys: const [Keys.tags],
      ),
      body: Scrollbar(
        child: ListView(
          shrinkWrap: false,
          padding: EdgeInsets.all(5),
          children: [
            if (!Platform().isDesktop && notificationFeatures.isNotEmpty)
              ListGroup(
                title: SettingsLocalizations.notifications,
                unsizedChildren: notificationFeatures
                    .map(
                      (feature) => SwitchListTile(
                        title: Text(
                          feature.name,
                          style: TextStyle(
                            color: ThemeWidget.of(context).textColor,
                          ),
                        ),
                        activeColor: Theme.of(context).accentColor,
                        value: Static.storage.getBool(
                                Keys.notifications(feature.featureKey)) ??
                            true,
                        onChanged: (value) async {
                          setState(() {
                            Static.storage.setBool(
                              Keys.notifications(feature.featureKey),
                              value,
                            );
                          });
                          await Static.tags.syncDevice(
                            context,
                            FeaturesWidget.of(context).features,
                          );
                        },
                      ),
                    )
                    .toList(),
                children: const [],
              ),
            for (final feature in regularFeatures
                .where((feature) => feature.extraSettings.isNotEmpty))
              ListGroup(
                title: feature.name,
                unsizedChildren: feature.extraSettings
                    .map((setting) => SwitchListTile(
                          title: Text(
                            setting.name,
                            style: TextStyle(
                              color: ThemeWidget.of(context).textColor,
                            ),
                          ),
                          activeColor: Theme.of(context).accentColor,
                          value: Static.storage.getBool(setting.key) ??
                              setting.defaultValue,
                          onChanged: (value) async {
                            setState(() {
                              Static.storage.setBool(
                                setting.key,
                                value,
                              );
                            });
                          },
                        ))
                    .toList()
                    .cast<Widget>()
                    .toList(),
                children: const [],
              ),
            ListGroup(
              title: SettingsLocalizations.design,
              unsizedChildren: [
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: Static.storage.getInt(Keys.design) ?? 0,
                      onChanged: (value) {
                        setState(() {
                          Static.storage.setInt(Keys.design, value);
                        });
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
                ),
              ],
              children: const [],
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
                    FeaturesWidget.of(context)
                        .features
                        .forEach((f) => f.loader?.clear());
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
          ]
              .map((x) => SizeLimit(
                    child: x,
                  ))
              .toList()
              .cast<Widget>(),
        ),
      ),
    );
  }
}
