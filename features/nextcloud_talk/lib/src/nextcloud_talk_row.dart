import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_talk/nextcloud_talk.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'nextcloud_talk_message_widget.dart';
import 'nextcloud_talk_model.dart';
import 'nextcloud_talk_utils.dart';

// ignore: public_member_api_docs
class NextcloudTalkRow extends PreferredSize {
  // ignore: public_member_api_docs
  const NextcloudTalkRow({
    @required this.chat,
  });

  // ignore: public_member_api_docs
  final NextcloudTalkChat chat;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) => CustomRow(
        leading: Stack(
          children: [
            if (chat.type == ConversationType.oneToOne)
              SizedBox(
                height: customRowHeight - 30,
                width: customRowHeight - 30,
                child: CustomCachedNetworkImage(
                  provider: CustomCachedNetworkImageAvatarProvider(
                    avatarClient: NextcloudTalkWidget.of(context)
                        .feature
                        .loader
                        .client
                        .avatar,
                    username: chat.name,
                    size: customRowHeight.toInt() - 30,
                  ),
                  height: customRowHeight - 30,
                  width: customRowHeight - 30,
                ),
              )
            else
              Icon(
                Icons.group,
                color: ThemeWidget.of(context).textColorLight,
              ),
            if (chat.unreadMessages > 0)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 6.5,
                  width: 6.5,
                  margin: EdgeInsets.only(
                    top: 1.5,
                    right: 1.5,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: 0.1,
                        blurRadius: 0.1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat.displayName,
          style: TextStyle(
            fontSize: 17,
            color: chat.unreadMessages > 0
                ? Theme.of(context).accentColor
                : Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: NextcloudTalkMessageWidget(
          message: chat.lastMessage,
          includeActorName: true,
          singleLine: true,
          overflow: TextOverflow.ellipsis,
        ),
        last: Text(
          timeago.format(
            chat.lastActivity,
            locale: 'de_short',
          ),
          style: TextStyle(
            fontWeight: FontWeight.w100,
          ),
        ),
      );
}
