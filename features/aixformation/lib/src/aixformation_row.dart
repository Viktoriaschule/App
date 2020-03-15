import 'package:aixformation/aixformation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class AiXformationRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const AiXformationRow({
    @required this.post,
    @required this.posts,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Post post;

  // ignore: public_member_api_docs
  final List<Post> posts;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () async {
          if (Platform().isMobile) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AiXformationPost(
                  post: post,
                  posts: posts,
                ),
              ),
            );
          } else {
            await launch(post.url);
          }
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            height: 40,
            child: CustomRow(
              leading: Platform().isWeb
                  ? Stack(
                      children: [
                        getLoadingPlaceholder(context),
                        FadeInImage.memoryNetwork(
                          height: 40,
                          width: 40,
                          placeholder: kTransparentImage,
                          image: post.imageUrl,
                        ),
                      ],
                    )
                  : CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      height: 40,
                      width: 40,
                      placeholder: (context, url) =>
                          getLoadingPlaceholder(context),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: ThemeWidget.of(context).textColor,
                      ),
                    ),
              title: post.title,
              titleColor: ThemeWidget.of(context).textColor,
              titleFontWeight: FontWeight.normal,
              subtitle: IconsTexts(
                icons: [
                  Icons.event,
                  Icons.person,
                ],
                texts: [
                  outputDateFormat.format(post.date),
                  post.author ?? '',
                ],
              ),
            ),
          ),
        ),
      );
}
