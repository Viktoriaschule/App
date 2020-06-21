import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_talk/nextcloud_talk.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_keys.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_model.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'nextcloud_talk_localizations.dart';

// ignore: public_member_api_docs
class NextcloudTalkNotificationLevelDialog extends StatefulWidget {
  // ignore: public_member_api_docs
  const NextcloudTalkNotificationLevelDialog({
    @required this.chats,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<NextcloudTalkChat> chats;

  @override
  _NextcloudTalkNotificationLevelDialogState createState() =>
      _NextcloudTalkNotificationLevelDialogState();
}

class _NextcloudTalkNotificationLevelDialogState
    extends State<NextcloudTalkNotificationLevelDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        contentPadding: EdgeInsets.only(left: 5, right: 5, top: 10),
        title: Text(
          NextcloudTalkLocalizations.talkNotifications,
          style: TextStyle(
            color: ThemeWidget.of(context).textColor,
          ),
        ),
        children: [
          DialogContentWrapper(
            children: [
              Text(NextcloudTalkLocalizations
                  .talkNotificationsNotificationLevelInfo),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_loading)
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Static.storage.setBool(
                            NextcloudTalkKeys
                                .automaticallyChangeNotificationLevel,
                            false,
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.no),
                      ),
                    ),
                  if (!_loading)
                    Container(
                      width: 20,
                    ),
                  Expanded(
                    child: CustomButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() {
                                _loading = true;
                              });
                              Static.storage.setBool(
                                NextcloudTalkKeys
                                    .automaticallyChangeNotificationLevel,
                                true,
                              );
                              final loader = NextcloudTalkWidget.of(context)
                                  .feature
                                  .loader;
                              final conversationManagement =
                                  loader.client.talk.conversationManagement;
                              for (final chat in widget.chats) {
                                await conversationManagement
                                    .setNotificationLevel(
                                  chat.token,
                                  NotificationLevel.always,
                                );
                              }
                              Navigator.of(context).pop();
                              await loader.loadOnline(context, force: true);
                            },
                      child: _loading
                          ? CustomCircularProgressIndicator(
                              height: 25,
                              width: 25,
                              color: Theme.of(context).primaryColor,
                            )
                          : Text(AppLocalizations.yes),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}
