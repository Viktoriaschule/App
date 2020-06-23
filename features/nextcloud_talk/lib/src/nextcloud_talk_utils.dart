import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class CustomCachedNetworkImageAvatarProvider
    implements CustomCachedNetworkImageProvider {
  // ignore: public_member_api_docs
  CustomCachedNetworkImageAvatarProvider({
    @required this.username,
    @required this.size,
    @required this.avatarClient,
  });

  // ignore: public_member_api_docs
  final String username;

  // ignore: public_member_api_docs
  final int size;

  // ignore: public_member_api_docs
  final AvatarClient avatarClient;

  @override
  String get identifier => 'talk-$username-$size';

  @override
  Future<Uint8List> loadImage() async =>
      base64.decode(await avatarClient.getAvatar(username, size));

  @override
  Widget imageWrapper(BuildContext context, Uint8List image) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: MemoryImage(image),
          ),
        ),
      );
}
