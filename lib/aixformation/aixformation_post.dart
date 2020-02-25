import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaapp/aixformation/aixformation_utils.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class AiXformationPost extends StatefulWidget {
  // ignore: public_member_api_docs
  const AiXformationPost({
    @required this.post,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Post post;

  @override
  _AiXformationPostState createState() => _AiXformationPostState();
}

class _AiXformationPostState extends State<AiXformationPost>
    with AfterLayoutMixin<AiXformationPost> {
  final _flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void dispose() {
    _flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _flutterWebviewPlugin.onUrlChanged.listen((url) async {
      if (!url.contains(widget.post.url) && await canLaunch(url)) {
        await launch(url);
        _flutterWebviewPlugin.dispose();
      }
    });
    _flutterWebviewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        await _flutterWebviewPlugin.evalJavascript(_CSStoJS([
          if (ThemeWidget.of(context).brightness == Brightness.dark) ...[
            'h1, h2, h3, h4, h5, h6, strong, b, p, i, a, span, div {color: #${_colorToHexString(ThemeWidget.of(context).textColor)} !important}',
            'div {background-color: #${_colorToHexString(Theme.of(context).backgroundColor)} !important}',
          ],
          'header, .p-menu {display: none}',
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
        initialChild: Container(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: getLoadingPlaceholder(context),
          ),
        ),
        appBar: AppBar(
          title: Text(
            'AiXformation',
            style: TextStyle(
              color: ThemeWidget.of(context).textColor,
            ),
          ),
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: ThemeWidget.of(context).textColor,
              ),
              onPressed: () => launch(widget.post.url),
            ),
            if (Platform().isMobile)
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: ThemeWidget.of(context).textColor,
                ),
                onPressed: () {
                  Share.share(widget.post.url);
                },
              ),
          ],
        ),
      );
}
