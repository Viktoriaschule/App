import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ginko/aixformation/aixformation_post.dart';
import 'package:ginko/aixformation/aixformation_utils.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/custom_row.dart';
import 'package:ginko/utils/icons_texts.dart';
import 'package:ginko/models/models.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: public_member_api_docs
class AiXformationRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const AiXformationRow({
    @required this.post,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Post post;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AiXformationPost(
                post: post,
              ),
            ),
          );
        },
        child: CustomRow(
          leading: Platform().isWeb
              ? Stack(
                  children: [
                    getLoadingPlaceholder(context),
                    FadeInImage.memoryNetwork(
                      height: 50,
                      width: 50,
                      placeholder: kTransparentImage,
                      image: post.thumbnailUrl,
                    ),
                  ],
                )
              : CachedNetworkImage(
                  imageUrl: post.thumbnailUrl,
                  placeholder: (context, url) => getLoadingPlaceholder(context),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
          title: post.title,
          titleFontWeight: FontWeight.w500,
          titleColor: Color.fromARGB(180, 0, 0, 0),
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
