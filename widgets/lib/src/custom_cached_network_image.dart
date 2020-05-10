import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utils/utils.dart';

import 'custom_circular_progress_indicator.dart';

// ignore: public_member_api_docs
class CustomCachedNetworkImage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomCachedNetworkImage({
    @required this.imageUrl,
    this.width,
    this.height,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final String imageUrl;

  @override
  _CustomCachedNetworkImageState createState() =>
      _CustomCachedNetworkImageState();
}

class _CustomCachedNetworkImageState extends State<CustomCachedNetworkImage>
    with AfterLayoutMixin<CustomCachedNetworkImage> {
  bool _initialized = false;
  String _cacheDir;
  Platform _platform;

  @override
  void afterFirstLayout(BuildContext context) {
    if (Platform().isDesktop) {
      getTemporaryDirectory().then((cacheDir) {
        if (mounted) {
          setState(() {
            _cacheDir = cacheDir.path;
            _initialized = true;
          });
        }
      });
    }
  }

  @override
  void initState() {
    _platform = Platform();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget loading = Container(
      height: widget.height,
      width: widget.width,
      child: Center(
        child: CustomCircularProgressIndicator(
          width: widget.width / 2,
          height: widget.height / 2,
        ),
      ),
    );
    final Widget error = Icon(
      Icons.error,
      color: ThemeWidget.of(context).textColor,
    );
    if (_platform.isMobile) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        height: widget.height,
        width: widget.width,
        placeholder: (context, url) => loading,
        errorWidget: (context, url, error) => Icon(Icons.error_outline),
      );
    }
    if (_initialized || _platform.isWeb) {
      Future future;
      final path =
          '$_cacheDir/${widget.imageUrl.split('//').sublist(1).join('//').replaceAll('/', '-')}';
      if (_platform.isDesktop) {
        if (File(path).existsSync()) {
          future = File(path).readAsBytes();
        }
      }
      future ??= Dio().get(
        widget.imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      return Center(
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is Response) {
                if (_platform.isDesktop) {
                  if (!Directory(_cacheDir).existsSync()) {
                    Directory(_cacheDir).createSync(recursive: true);
                  }
                  File(path).writeAsBytesSync(snapshot.data.data);
                }
                return Image.memory(snapshot.data.data);
              } else {
                return Image.memory(snapshot.data);
              }
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return error;
            } else {
              return loading;
            }
          },
        ),
      );
    }
    return Container();
  }
}
