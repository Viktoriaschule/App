import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/utils/custom_grid_tabs_list.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class CustomGrid extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomGrid({
    @required this.children,
    @required this.type,
    @required this.columnPrepend,
    this.append,
    this.childrenRowPrepend,
    this.appendRowPrepend,
    this.initialHorizontalIndex = 0,
    this.tabsChildrenWrap,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Widget> childrenRowPrepend;

  // ignore: public_member_api_docs
  final List<Widget> appendRowPrepend;

  // ignore: public_member_api_docs
  final List<String> columnPrepend;

  /// First columns then rows
  final List<List<Widget>> children;

  /// First columns then rows
  final List<List<Widget>> append;

  // ignore: public_member_api_docs
  final CustomGridType type;

  // ignore: public_member_api_docs
  final int initialHorizontalIndex;

  // ignore: public_member_api_docs
  final WidgetCallback tabsChildrenWrap;

  @override
  _CustomGridState createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    if (widget.type == CustomGridType.tabs) {
      _tabController = TabController(
        vsync: this,
        length: widget.children.length,
        initialIndex: widget.initialHorizontalIndex,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.type == CustomGridType.tabs) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == CustomGridType.tabs) {
      return DefaultTabController(
        length: widget.children.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.children
                .map((c) => Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.columnPrepend[widget.children.indexOf(c)],
                        style: TextStyle(
                          color: textColor(context),
                        ),
                      ),
                    ))
                .toList(),
          ),
          body: TabBarView(
            controller: _tabController,
            children: widget.children
                .map((tab) => CustomGridTabsList(
                      tab: tab,
                      append: widget.append,
                      wrap: widget.tabsChildrenWrap,
                      children: widget.children,
                    ))
                .toList(),
          ),
        ),
      );
    }
    final childrenCount = (widget.children.map((c) => c.length).toList()
          ..sort())
        .reversed
        .toList()[0];
    final appendCount = widget.append != null
        ? (widget.children
                .map((c) => widget.append[widget.children.indexOf(c)].length)
                .toList()
                  ..sort())
            .reversed
            .toList()[0]
        : 0;
    return Container(
      color: backgroundColor(context),
      child: Scrollbar(
        child: ListView(
          shrinkWrap: true,
          children: List.generate(
            childrenCount + appendCount + 1,
            (row) => Container(
              decoration: row == 0 ||
                      (row >= childrenCount &&
                          row < childrenCount + appendCount)
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: textColor(context),
                        ),
                      ),
                    )
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  widget.children.length +
                      (widget.childrenRowPrepend != null ? 1 : 0),
                  (column) {
                    Widget child = Container();
                    if (row == 0 && column == 0) {
                      child = Container();
                    } else if (row == 0) {
                      child = Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        alignment: Alignment.topCenter,
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          widget.columnPrepend[column - 1],
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor(context),
                          ),
                        ),
                      );
                    } else if (row <= childrenCount) {
                      if (column == 0 && widget.childrenRowPrepend != null) {
                        child = widget.childrenRowPrepend[row - 1];
                      } else {
                        if (widget.children[column - 1].length > row - 1) {
                          child = widget.children[column - 1][row - 1];
                        }
                      }
                    } else if (widget.append != null) {
                      final index = row - childrenCount - 1;
                      if (column == 0 && widget.appendRowPrepend != null) {
                        child = widget.appendRowPrepend[index];
                      } else {
                        if (widget.append[column - 1].length > index) {
                          child = widget.append[column - 1][index];
                        }
                      }
                    }
                    return Expanded(
                      flex: column == 0 ? 1 : 3,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef WidgetCallback = Widget Function(Widget child);

// ignore: public_member_api_docs
enum CustomGridType {
  // ignore: public_member_api_docs
  tabs,
  // ignore: public_member_api_docs
  grid,
}
