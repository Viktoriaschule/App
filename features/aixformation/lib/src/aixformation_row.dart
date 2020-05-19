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
            provider: CustomCachedNetworkImageUrlProvider(
              imageUrl: post.imageUrl,
            ),
            height: customRowHeight - 26,
            width: customRowHeight - 26,
          ),
          title: Text(
            post.title,
            style: TextStyle(
              fontSize: 17,
              color: ThemeWidget.of(context).textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
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
