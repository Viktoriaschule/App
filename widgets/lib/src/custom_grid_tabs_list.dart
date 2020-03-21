import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utils/utils.dart';

import 'custom_grid_info_page.dart';
import 'custom_refresh_indicator.dart';

// ignore: public_member_api_docs
class CustomGridTabsList extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomGridTabsList({
    @required this.tab,
    @required this.children,
    @required this.extraInfoTitles,
    @required this.extraInfoChildren,
    @required this.extraInfoCounts,
    @required this.onRefresh,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Widget> tab;

  // ignore: public_member_api_docs
  final List<List<Widget>> children;

  // ignore: public_member_api_docs
  final List<String> extraInfoTitles;

  /// All children that should be shown after click on the extra information button
  final List<List<Widget>> extraInfoChildren;

  /// The count of all extra information
  final List<int> extraInfoCounts;

  // ignore: public_member_api_docs
  final Future<StatusCode> Function() onRefresh;

  @override
  _CustomGridTabsListState createState() => _CustomGridTabsListState();
}

class _CustomGridTabsListState extends State<CustomGridTabsList> {
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            child: CustomRefreshIndicator(
              loadOnline: widget.onRefresh,
              child: Scrollbar(
                child: ListView(
                  children: widget.tab,
                ),
              ),
            ),
          ),
          if (widget.extraInfoChildren != null &&
              widget.extraInfoChildren[widget.children.indexOf(widget.tab)]
                  .isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomGridInfoPage(
                          title: widget.extraInfoTitles[
                              widget.children.indexOf(widget.tab)],
                          children: widget.extraInfoChildren[
                              widget.children.indexOf(widget.tab)],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          Icons.info_outline,
                          size: 25,
                          color: widget.extraInfoCounts[
                                      widget.children.indexOf(widget.tab)] >
                                  0
                              ? ThemeWidget.of(context).textColor
                              : ThemeWidget.of(context)
                                  .textColor
                                  .withOpacity(0.5),
                        ),
                      ),
                      if (widget.extraInfoCounts[
                              widget.children.indexOf(widget.tab)] !=
                          0)
                        Positioned(
                          right: 0,
                          child: Container(
                            margin: EdgeInsets.only(top: 13.5, right: 13.5),
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              widget.extraInfoCounts[
                                      widget.children.indexOf(widget.tab)]
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
}
