import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ginko/aixformation/aixformation_row.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';

// ignore: public_member_api_docs
class AiXformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('AiXformation'),
        ),
        body: Scrollbar(
          child: ListView(
            shrinkWrap: true,
            children: Static.aiXformation.data.posts
                .map((post) => Center(
                      child: SizeLimit(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: AiXformationRow(
                            post: post,
                          ),
                        ),
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ),
      );
}
