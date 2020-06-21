import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import '../nextcloud_talk.dart';
import 'nextcloud_talk_localizations.dart';

// ignore: public_member_api_docs
class NextcloudTalkLoginDialog extends StatefulWidget {
  // ignore: public_member_api_docs
  const NextcloudTalkLoginDialog({
    @required this.init,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final LoginFlowInit init;

  @override
  _NextcloudTalkLoginDialogState createState() =>
      _NextcloudTalkLoginDialogState();
}

class _NextcloudTalkLoginDialogState extends State<NextcloudTalkLoginDialog>
    with AfterLayoutMixin<NextcloudTalkLoginDialog> {
  FlutterWebviewPlugin _flutterWebviewPlugin = FlutterWebviewPlugin();
  bool _loading = false;
  String _currentURL;

  @override
  Future afterFirstLayout(BuildContext context) async {
    _flutterWebviewPlugin.onUrlChanged.listen((url) async {
      _currentURL = url;
    });
    _flutterWebviewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        if (_currentURL ==
            '${BaseUrl.nextcloud.url}/index.php/login/v2/grant') {
          _flutterWebviewPlugin.dispose();
          _flutterWebviewPlugin = null;
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _loading = false;
    if (_flutterWebviewPlugin != null) {
      _flutterWebviewPlugin.dispose();
      _flutterWebviewPlugin = null;
    }
    super.dispose();
  }

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
            DialogContentWrapper(children: [
              Text(NextcloudTalkLocalizations.talkNotificationsLoginInfo),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_loading)
                    Expanded(
                      child: CustomButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.cancel),
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
                              final client = NextCloudClient.withoutLogin(
                                BaseUrl.nextcloud.url,
                                appType: appType,
                                language: language,
                              );
                              setState(() {
                                _loading = true;
                              });
                              // ignore: unawaited_futures
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => WebviewScaffold(
                                  url: widget.init.login,
                                  hidden: true,
                                  scrollBar: false,
                                  initialChild: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    child: Center(
                                      child: CustomCircularProgressIndicator(),
                                    ),
                                  ),
                                  headers: {
                                    'User-Agent': appType.userAgent,
                                    'Accept-Language': language,
                                  },
                                  appBar: CustomAppBar(
                                    title: NextcloudTalkLocalizations.nextcloud,
                                    loadingKeys: const [],
                                  ),
                                ),
                              ));

                              while (_loading) {
                                try {
                                  Navigator.of(context).pop(await client.login
                                      .pollLogin(widget.init));
                                  break;
                                  // ignore: empty_catches, avoid_catches_without_on_clauses
                                } catch (e) {
                                  await Future.delayed(Duration(seconds: 1));
                                }
                              }
                            },
                      child: _loading
                          ? CustomCircularProgressIndicator(
                              height: 25,
                              width: 25,
                              color: Theme.of(context).primaryColor,
                            )
                          : Text(AppLocalizations.login),
                    ),
                  ),
                ],
              ),
            ])
          ]);
}
