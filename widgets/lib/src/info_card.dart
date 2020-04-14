import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:widgets/src/list_group.dart';

/// The info card for a feature
abstract class InfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const InfoCard({
    @required this.date,
    this.maxHeight,
    Key key,
  }) : super(key: key);

  /// The date for the info card
  final DateTime date;

  /// The maximum height for the info card
  final double maxHeight;
}

// ignore: public_member_api_docs
abstract class InfoCardState<T extends InfoCard> extends Interactor<T> {
  @override
  ListGroup build(BuildContext context);
}
