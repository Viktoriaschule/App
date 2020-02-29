import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'aixformation_model.dart';
import 'aixformation_utils.dart';

// ignore: public_member_api_docs
class AiXformationPost extends StatefulWidget {
  // ignore: public_member_api_docs
  const AiXformationPost({
    @required this.post,
    @required this.posts,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Post post;

  // ignore: public_member_api_docs
  final List<Post> posts;

  @override
  _AiXformationPostState createState() => _AiXformationPostState();
}

class _AiXformationPostState extends State<AiXformationPost>
    with AfterLayoutMixin<AiXformationPost> {
  final _flutterWebviewPlugin = FlutterWebviewPlugin();
  String _currentURL;

  @override
  void initState() {
    _currentURL = widget.post.url;
    super.initState();
  }

  @override
  void dispose() {
    _flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _flutterWebviewPlugin.onUrlChanged.listen((url) async {
      setState(() {
        _currentURL = url;
      });
    });
    _flutterWebviewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        await _flutterWebviewPlugin.evalJavascript(_CSStoJS([
          if (ThemeWidget.of(context).brightness == Brightness.dark) ...[
            'h1, h2, h3, h4, h5, h6, strong, b, p, i, a, span, div, figcaption, button {color: #${_colorToHexString(ThemeWidget.of(context).textColor)} !important}',
            'div, amp-user-notification, article, textarea, .mh-footer {background-color: #${_colorToHexString(Theme.of(context).backgroundColor)} !important}',
            'amp-user-notification {border: none !important}',
            'footer {margin: 0 !important}',
            'footer * {border: 0 !important}',
            'button {background-color: #${_colorToHexString(Theme.of(context).primaryColor)} !important}'
          ],
          'header, .p-menu, .mh-subheader, .mh-header, .mh-header-nav-mobile, .mh-footer-nav-mobile, .search-form {display: none !important}',
        ]));
      }
    });
  }

  String _colorToHexString(Color color) =>
      color.value.toRadixString(16).substring(2);

  // ignore: non_constant_identifier_names
  String _CSStoJS(List<String> stylesheet) =>
      'const sheet = new CSSStyleSheet();sheet.replaceSync("${stylesheet.join('')}");document.adoptedStyleSheets = [sheet];';

  @override
  Widget build(BuildContext context) => WebviewScaffold(
        url: widget.post.url,
        hidden: true,
        scrollBar: false,
        invalidUrlRegex: '^(?!(${[
          ...widget.posts,
          widget.post
        ].map((p) => p.url.replaceAll('/', '\\/')).join('|')}).*\$).*',
        initialChild: Container(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: getLoadingPlaceholder(context),
          ),
        ),
        appBar: CustomAppBar(
          title: 'AiXformation',
          loadingKeys: const [],
          actions: [
            IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: ThemeWidget.of(context).textColor,
              ),
              onPressed: () => launch(_currentURL),
            ),
            if (Platform().isMobile)
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: ThemeWidget.of(context).textColor,
                ),
                onPressed: () {
                  Share.share(_currentURL);
                },
              ),
          ],
        ),
      );
}
