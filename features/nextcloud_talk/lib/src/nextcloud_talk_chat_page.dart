import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_keys.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_loader.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import '../nextcloud_talk.dart';
import 'nextcloud_talk_localizations.dart';
import 'nextcloud_talk_message_widget.dart';
import 'nextcloud_talk_model.dart';

// ignore: public_member_api_docs
class NextcloudTalkChatPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const NextcloudTalkChatPage({
    @required this.chat,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final NextcloudTalkChat chat;

  @override
  _NextcloudTalkChatPageState createState() => _NextcloudTalkChatPageState();
}

class _NextcloudTalkChatPageState extends State<NextcloudTalkChatPage>
    with AfterLayoutMixin<NextcloudTalkChatPage> {
  List<NextcloudTalkMessage> _messages;
  final ScrollController _scrollController = ScrollController();
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  NextcloudTalkLoader _loader;
  Timer _autoRefresh;

  @override
  void initState() {
    _messages = widget.chat.loadOfflineMessages();
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      _loader = NextcloudTalkWidget.of(context).feature.loader;
      _autoRefresh = Timer.periodic(
          Duration(
            seconds: 30,
          ), (timer) {
        _loadOnlineMessages(sendEvent: false);
      });
      _loadOnlineMessages();
    }
  }

  @override
  void dispose() {
    if (_autoRefresh != null) {
      _autoRefresh.cancel();
      _autoRefresh = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loader = NextcloudTalkWidget.of(context).feature.loader;
    loader.client.talk.messageManagement.getMessages(widget.chat.token);
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.chat.displayName,
        loadingKeys: const [NextcloudTalkKeys.nextcloudTalk],
      ),
      body: (_messages == null || _messages.isEmpty)
          ? Center(
              child: EmptyList(title: NextcloudTalkLocalizations.noMessages),
            )
          : Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(10),
                    itemCount: _messages.length,
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context, index) => Center(
                      child: SizeLimit(
                        maxWidth: 900,
                        child: Row(
                          children: [
                            if (_messages[_messages.length - index - 1]
                                    .actorId ==
                                Static.user.username)
                              Expanded(
                                flex: 10,
                                child: Container(),
                              ),
                            Expanded(
                              flex: 90,
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: index == _messages.length - 1
                                        ? 0
                                        : _messages[_messages.length -
                                                        index -
                                                        1]
                                                    .actorId !=
                                                _messages[_messages.length -
                                                        index -
                                                        2]
                                                    .actorId
                                            ? 20
                                            : 5),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                    ThemeWidget.of(context).textColor,
                                    Theme.of(context).backgroundColor,
                                    0.9,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.chat.type !=
                                            ConversationType.oneToOne &&
                                        _messages[_messages.length - index - 1]
                                                .actorId !=
                                            Static.user.username &&
                                        (index == _messages.length - 1 ||
                                            _messages[_messages.length -
                                                        index -
                                                        1]
                                                    .actorId !=
                                                _messages[_messages.length -
                                                        index -
                                                        2]
                                                    .actorId))
                                      Text(
                                        _messages[_messages.length - index - 1]
                                            .actorDisplayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    NextcloudTalkMessageWidget(
                                      message: _messages[
                                          _messages.length - index - 1],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_messages[_messages.length - index - 1]
                                    .actorId !=
                                Static.user.username)
                              Expanded(
                                flex: 10,
                                child: Container(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1),
                Container(
                  margin: EdgeInsets.only(
                    left: 20,
                    right: 4,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _textController,
                          onChanged: (text) {
                            setState(() {
                              _isComposing = text.isNotEmpty;
                            });
                          },
                          onSubmitted: _isComposing ? _handleSubmitted : null,
                          decoration: InputDecoration.collapsed(
                            hintText: NextcloudTalkLocalizations.writeMessage,
                          ),
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: _isComposing
                                ? Theme.of(context).accentColor
                                : null,
                          ),
                          onPressed: _isComposing
                              ? () => _handleSubmitted(_textController.text)
                              : null,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _loadOnlineMessages({bool sendEvent = true}) {
    final eventBus = EventBus.of(context);
    final loadingState = LoadingState.of(context);
    if (sendEvent) {
      _loader.sendLoadingEvent(loadingState, eventBus);
    }
    widget.chat
        .loadOnlineMessages(_loader.client.talk.messageManagement)
        .then((messages) async {
      if (mounted) {
        setState(() => _messages = messages);
        try {
          await _loader.client.talk.messageManagement.markAsRead(
            widget.chat.token,
            widget.chat.lastMessage.id,
          );
          await _loader.loadOnline(
            context,
            force: true,
          );
        } on RequestException catch (e, stacktrace) {
          print(e);
          print(stacktrace);
        }
      }
      if (sendEvent) {
        _loader.sendLoadedEvent(loadingState, eventBus);
      }
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    _focusNode.requestFocus();
    _scrollController.animateTo(
      0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    final loader = NextcloudTalkWidget.of(context).feature.loader
      ..sendLoadingEvent(LoadingState.of(context), EventBus.of(context));
    loader.client.talk.messageManagement
        .sendMessage(widget.chat.token, text)
        .then((messages) {
      if (mounted) {
        _loadOnlineMessages();
        _loader.loadOnline(context, force: true);
      } else {
        _loader.sendLoadedEvent(LoadingState.of(context), EventBus.of(context));
      }
    });
  }
}