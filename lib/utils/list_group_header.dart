import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: public_member_api_docs
class ListGroupHeader extends StatelessWidget {
  // ignore: public_member_api_docs
  const ListGroupHeader({
    @required this.title,
    this.center = false,
    this.counter = 0,
    this.onTap,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final bool center;

  // ignore: public_member_api_docs
  final int counter;

  // ignore: public_member_api_docs
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          height: TabBar(
                tabs: const [],
              ).preferredSize.height +
              1,
          decoration: getScreenSize(MediaQuery.of(context).size.width) !=
                  ScreenSize.small
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.black38,
                    ),
                  ),
                )
              : null,
          child: AppBar(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: getScreenSize(MediaQuery.of(context).size.width) ==
                    ScreenSize.small
                ? (Platform().isWeb ? 1 : 3)
                : 0,
            actions: [
              if (counter > 0)
                Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 9),
                    child: Text(
                      '+${counter >= 10 ? counter : '$counter '}',
                      style: GoogleFonts.ubuntuMono(
                        fontSize: 20,
                        textStyle: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
