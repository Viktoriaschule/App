import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'aixformation_model.dart';
import 'aixformation_post.dart';

// ignore: public_member_api_docs
class AiXformationRow extends PreferredSize {
  // ignore: public_member_api_docs
  const AiXformationRow({
    @required this.post,
    @required this.posts,
  });

  // ignore: public_member_api_docs
  final Post post;

  // ignore: public_member_api_docs
  final List<Post> posts;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

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
        child: CustomRow(
          leading: CustomCachedNetworkImage(
            imageUrl: post.imageUrl,
            height: 60,
            width: 60,
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
      );
}
