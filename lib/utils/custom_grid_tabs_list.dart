import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/utils/theme.dart';

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
            2.5 +
        2;
    final content = Column(
      children: [
        ...widget.tab,
      ],
    );
    return Stack(
      children: [
        Container(
          color: backgroundColor(context),
          child: Scrollbar(
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: [
                if (widget.append == null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: contentHeight,
                    ),
                    child: content,
                  ),
                if (widget.append != null)
                  Container(
                    margin: EdgeInsets.only(
                      bottom: contentHeight - widget.tab.length * 60,
                    ),
                    child: content,
                  ),
                if (widget.append != null)
                  ...widget.append[widget.children.indexOf(widget.tab)]
              ],
            ),
          ),
        ),
        if (widget.append != null)
          Container(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              opacity: _offset > 10 ? 0 : 1,
              duration: Duration(milliseconds: 100),
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(10),
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
  }
}
