import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ginko/aixformation/aixformation_utils.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/icons_texts.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/models/models.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: public_member_api_docs
class AiXformationPost extends StatelessWidget {
  // ignore: public_member_api_docs
  const AiXformationPost({
    @required this.post,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Post post;

  Widget _image(BuildContext context, String src) => Platform().isWeb
      ? Stack(
          children: [
            getLoadingPlaceholder(context),
            FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: src,
            ),
          ],
        )
      : CachedNetworkImage(
          imageUrl: src,
          placeholder: (context, url) => getLoadingPlaceholder(context),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );

  void _showImage(BuildContext context, String src) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _image(context, src),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('AiXformation'),
          actions: [
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () async {
                final url = post.url;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            if (Platform().isMobile)
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(post.url);
                },
              ),
          ],
        ),
        body: Scrollbar(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            children: [
              Column(
                children: [
                  SizeLimit(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),
                        IconsTexts(
                          icons: [
                            Icons.event,
                            Icons.person,
                          ],
                          texts: [
                            outputDateFormat.format(post.date),
                            post.author,
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: GestureDetector(
                            onTap: () => _showImage(context, post.fullUrl),
                            child: _image(context, post.fullUrl),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: SizeLimit(
                      child: Html(
                        data: post.content,
                        onLinkTap: (url) async {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw Exception('Could not launch $url');
                          }
                        },
                        onImageTap: (src) => _showImage(context, src),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
