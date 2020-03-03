import 'package:flutter/cupertino.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/src/list_group.dart';

/// The info card for a feature
abstract class InfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const InfoCard({@required this.date, Key key}) : super(key: key);

  /// The date for the info card
  final DateTime date;
}

// ignore: public_member_api_docs
abstract class InfoCardState<T extends InfoCard> extends Interactor<T> {
  /// The list group widget for the content
  ListGroup getListGroup(BuildContext context, InfoCardUtils utils);

  @override
  Widget build(BuildContext context) {
    final utils = InfoCardUtils(context, widget.date);
    return getListGroup(context, utils);
  }
}
