import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/snapping_list_view.dart';

// ignore: public_member_api_docs
class CustomGridTabsList extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomGridTabsList({
    @required this.tab,
    @required this.children,
    @required this.append,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Widget> tab;

  // ignore: public_member_api_docs
  final List<List<Widget>> children;

  // ignore: public_member_api_docs
  final List<List<Widget>> append;

  @override
  _CustomGridTabsListState createState() => _CustomGridTabsListState();
}

class _CustomGridTabsListState extends State<CustomGridTabsList> {
  ScrollController _scrollController;
  double _offset = 0;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _offset = _scrollController.offset;
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentHeight = MediaQuery.of(context).size.height -
        TabBar(
              tabs: const [],
            ).preferredSize.height *
            2.5;
    final content = Column(
      children: [
        ...widget.tab,
      ],
    );
    final margin = contentHeight - widget.tab.length * 60 - 50;
    final animationProgress =
        double.parse((_offset / contentHeight).toStringAsPrecision(3));
    return Stack(
      children: [
        Container(
          color: Theme.of(context).backgroundColor,
          child: SnappingListView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            itemExtent: contentHeight,
            children: [
              if (widget.append == null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: contentHeight,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [content],
                    ),
                  ),
                ),
              if (widget.append != null)
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: !margin.isNegative ? margin : 0,
                  ),
                  child: Column(
                    children: [content],
                  ),
                ),
              if (widget.append != null)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ...widget.append[widget.children.indexOf(widget.tab)],
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (widget.append != null)
          Container(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  animationProgress < 0.5
                      ? _scrollController.position.maxScrollExtent
                      : 0,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                );
              },
              child: Container(
                padding: EdgeInsets.all(7.5),
                child: Transform.rotate(
                  angle: animationProgress * pi,
                  child: Icon(
                    Icons.expand_more,
                    size: 30,
                    color: ThemeWidget.of(context).textColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
