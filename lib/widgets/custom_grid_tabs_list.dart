import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_refresh_indicator.dart';
import 'package:viktoriaapp/widgets/snapping_list_view.dart';

// ignore: public_member_api_docs
class CustomGridTabsList extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomGridTabsList({
    @required this.tab,
    @required this.children,
    @required this.append,
    @required this.onRefresh,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Widget> tab;

  // ignore: public_member_api_docs
  final List<List<Widget>> children;

  // ignore: public_member_api_docs
  final List<List<Widget>> append;

  // ignore: public_member_api_docs
  final Future<StatusCodes> Function() onRefresh;

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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            children: [
              ...widget.tab,
            ],
          );
          final animationProgress = double.parse(
              (_offset / constraints.maxHeight).toStringAsPrecision(3));
          if (widget.append == null) {
            return Container(
              color: Theme.of(context).backgroundColor,
              height: constraints.maxHeight,
              child: CustomRefreshIndicator(
                loadOnline: widget.onRefresh,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [content],
                ),
              ),
            );
          }

          return Stack(
            children: [
              Container(
                color: Theme.of(context).backgroundColor,
                height: constraints.maxHeight,
                child: CustomRefreshIndicator(
                  loadOnline: widget.onRefresh,
                  child: SnappingListView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    itemExtent: constraints.maxHeight,
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          height: constraints.maxHeight,
                          child: Column(
                            children: [content],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Container(
                          height: constraints.maxHeight,
                          child: Column(
                            children: [
                              ...widget
                                  .append[widget.children.indexOf(widget.tab)],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          color: textColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
