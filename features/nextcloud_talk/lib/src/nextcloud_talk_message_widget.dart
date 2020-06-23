import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import '../nextcloud_talk.dart';
import 'nextcloud_talk_model.dart';
import 'nextcloud_talk_utils.dart';

// ignore: public_member_api_docs
class NextcloudTalkMessageWidget extends StatelessWidget {
  // ignore: public_member_api_docs
  const NextcloudTalkMessageWidget({
    @required this.message,
    this.overflow = TextOverflow.visible,
    this.includeActorName = false,
    this.singleLine = false,
  });

  // ignore: public_member_api_docs
  final NextcloudTalkMessage message;

  // ignore: public_member_api_docs
  final TextOverflow overflow;

  // ignore: public_member_api_docs
  final bool includeActorName;

  // ignore: public_member_api_docs
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> parts = [];
    if (includeActorName && message.actorId != Static.user.username) {
      var text = '';
      if (message.actorId.length <= 4) {
        text += message.actorDisplayName.split(' ').sublist(1).join(' ');
      } else {
        text += message.actorDisplayName.split(' ')[0];
      }
      text += ': ';
      parts.add(TextSpan(text: text));
    }
    final RegExp _urlRegex = RegExp(
      r'^((?:.|\n)*?)((?:https?):\/\/[^\s/$.?#].[^\s]*)$',
      caseSensitive: false,
    );
    final List<List<String>> data =
        message.message.split('\n').map((t) => t.split(' ')).toList();
    for (final line in data) {
      for (final part in line) {
        bool added = false;
        if (_urlRegex.hasMatch(part)) {
          added = true;
          parts.add(WidgetSpan(
            child: Container(
              margin: EdgeInsets.only(bottom: 2),
              child: InkWell(
                onTap: () => launch(part),
                child: Text(
                  part,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ));
        } else {
          for (final key in message.messageParameters.keys.toList()) {
            if (part == '{$key}') {
              added = true;
              final data = message.messageParameters[key];
              final type = data['type'];
              switch (type) {
                case 'file':
                  parts.add(WidgetSpan(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 2),
                      child: InkWell(
                        onTap: () => launch(data['link']),
                        child: Text(
                          data['name'],
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ));
                  break;
                case 'user':
                  parts.add(WidgetSpan(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          ThemeWidget.of(context).textColor,
                          Theme.of(context).backgroundColor,
                          0.75,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 2,
                              top: 2,
                              bottom: 2,
                            ),
                            height: 16,
                            width: 16,
                            child: CustomCachedNetworkImage(
                              provider: CustomCachedNetworkImageAvatarProvider(
                                avatarClient: NextcloudTalkWidget.of(context)
                                    .feature
                                    .loader
                                    .client
                                    .avatar,
                                username: data['id'],
                                size: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 2,
                              bottom: 2,
                              left: 20,
                              right: 4,
                            ),
                            child: Text(
                              data['name'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
                  break;
                default:
                  print('Type \'$type\' not implemented');
                  added = false;
              }
            }
          }
        }
        if (!added) {
          if (singleLine) {
            parts.add(TextSpan(text: part.replaceAll('\n', '')));
          } else {
            if (data.indexOf(line) != 0 && line.indexOf(part) == 0) {
              // Inserts a newline in front of the next line to prevent
              // a space that would appear in front of the line
              parts.add(TextSpan(text: '\n$part'));
            } else {
              parts.add(TextSpan(text: part));
            }
          }
        }
      }
    }

    return Text.rich(
      TextSpan(
        children: parts
            .map((p) => [
                  p,
                  if (parts.indexOf(p) != parts.length - 1)
                    TextSpan(
                      text: ' ',
                    ),
                ])
            .toList()
            .expand((x) => x)
            .toList(),
      ),
      style: TextStyle(
        height: 1.2,
      ),
      textAlign: TextAlign.start,
      overflow: overflow,
    );
  }
}
