import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utils/utils.dart';

import 'custom_circular_progress_indicator.dart';

// ignore: public_member_api_docs
class CustomCachedNetworkImage extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomCachedNetworkImage({
    @required this.provider,
    this.width,
    this.height,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final CustomCachedNetworkImageProvider provider;

  @override
  Widget build(BuildContext context) => Center(
        child: FutureBuilder<Uint8List>(
          future: _loadImage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SizedBox(
                height: height,
                width: width,
                child: provider.imageWrapper(context, snapshot.data) ??
                    Image.memory(snapshot.data),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Icon(
                Icons.error,
                color: ThemeWidget.of(context).textColor,
              );
            } else {
              return Container(
                height: height,
                width: width,
                child: Center(
                  child: CustomCircularProgressIndicator(
                    width: width != null ? width / 2 : null,
                    height: height != null ? height / 2 : null,
                  ),
                ),
              );
            }
          },
        ),
      );

  Future<Uint8List> _loadImage() async {
    if (_CustomCachedNetworkImageCache._cache[provider.identifier] != null) {
      return _CustomCachedNetworkImageCache._cache[provider.identifier];
    } else {
      final cacheDir = await getTemporaryDirectory();
      final platform = Platform();
      final path = '${cacheDir.path}/${provider.identifier}';
      Uint8List data;
      if (!platform.isWeb && File(path).existsSync()) {
        data = await File(path).readAsBytes();
      } else {
        data = await provider.loadImage();
        if (!platform.isWeb) {
          if (!cacheDir.existsSync()) {
            cacheDir.createSync(recursive: true);
          }
          File(path).writeAsBytesSync(data);
        }
      }
      _CustomCachedNetworkImageCache._cache[provider.identifier] = data;
      return data;
    }
  }
}

class _CustomCachedNetworkImageCache {
  static final Map<String, Uint8List> _cache = {};
}

// ignore: public_member_api_docs, one_member_abstracts
abstract class CustomCachedNetworkImageProvider {
  // ignore: public_member_api_docs
  Future<Uint8List> loadImage();

  // ignore: public_member_api_docs
  Widget imageWrapper(BuildContext context, Uint8List image);

  // ignore: public_member_api_docs
  String get identifier;
}

// ignore: public_member_api_docs
class CustomCachedNetworkImageUrlProvider
    implements CustomCachedNetworkImageProvider {
  // ignore: public_member_api_docs
  CustomCachedNetworkImageUrlProvider({
    @required this.imageUrl,
  });

  // ignore: public_member_api_docs
  final String imageUrl;

  @override
  Future<Uint8List> loadImage() async => (await Dio().get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      ))
          .data;

  @override
  String get identifier =>
      imageUrl.split('//').sublist(1).join('//').replaceAll('/', '-');

  @override
  Widget imageWrapper(BuildContext context, Uint8List image) => null;
}
