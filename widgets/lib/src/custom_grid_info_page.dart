import 'package:flutter/material.dart';

import 'custom_app_bar.dart';

// ignore: public_member_api_docs
class CustomGridInfoPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomGridInfoPage({
    @required this.title,
    @required this.children,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => CustomGridInfoPageState();
}

// ignore: public_member_api_docs
class CustomGridInfoPageState extends State<CustomGridInfoPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: widget.title,
          loadingKeys: const [],
        ),
        body: Scrollbar(
          child: ListView(
            children: widget.children,
          ),
        ),
      );
}
