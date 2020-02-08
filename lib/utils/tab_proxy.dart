import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ginko/utils/screen_sizes.dart';

// ignore: public_member_api_docs
class TabProxy extends StatefulWidget {
  // ignore: public_member_api_docs
  const TabProxy({
    @required this.tabs,
    @required this.controller,
    @required this.weekdays,
    this.threshold = ScreenSize.middle,
  }) : super();

  // ignore: public_member_api_docs
  final List<Widget> tabs;

  // ignore: public_member_api_docs
  final TabController controller;

  // ignore: public_member_api_docs
  final List<String> weekdays;

  // ignore: public_member_api_docs
  final ScreenSize threshold;

  @override
  State<StatefulWidget> createState() => _TabProxyState();
}

class _TabProxyState extends State<TabProxy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (getScreenSize(MediaQuery.of(context).size.width).index >=
        widget.threshold.index) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.tabs
              .map((tab) => Expanded(
                    flex: 1,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 20, bottom: 10),
                          alignment: Alignment.topCenter,
                          color: Colors.blue,
                          child: Text(
                            widget.weekdays[widget.tabs.indexOf(tab)],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        tab,
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    } else {
      return DefaultTabController(
        length: widget.tabs.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: TabBar(
            controller: widget.controller,
            indicatorColor: Theme.of(context).accentColor,
            indicatorWeight: 2.5,
            tabs: widget.weekdays
                .map((day) => Container(
                      padding: EdgeInsets.only(
                        left: 0,
                        top: 10,
                        right: 0,
                        bottom: 10,
                      ),
                      child: Text(day),
                    ))
                .toList(),
          ),
          body: TabBarView(
            controller: widget.controller,
            children: widget.tabs
                .map((tab) => Container(
                      height: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: tab,
                    ))
                .toList(),
          ),
        ),
      );
    }
  }
}
