import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:reservations/reservations.dart';
import 'package:reservations/src/reservations_events.dart';
import 'package:reservations/src/reservations_keys.dart';
import 'package:reservations/src/reservations_localizations.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'reservations_page.dart';
import 'reservations_row.dart';

// ignore: public_member_api_docs
class ReservationsInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const ReservationsInfoCard({
    @required DateTime date,
    double maxHeight,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

  @override
  _ReservationsCardState createState() => _ReservationsCardState();
}

class _ReservationsCardState extends InfoCardState<ReservationsInfoCard> {
  InfoCardUtils utils;

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<ReservationsUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup build(BuildContext context) {
    final loader = ReservationsWidget.of(context).feature.loader;

    final myReservations = loader.data?.myFutureReservations
            ?.where((r) => r.date.isSameDay(widget.date))
            ?.toList() ??
        [];

    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery.of(context).size.width),
      myReservations.length,
    );

    return ListGroup(
      loadingKeys: const [
        ReservationsKeys.reservations,
        ReservationsKeys.reservationGroups,
        ReservationsKeys.reservationList,
      ],
      heroId: ReservationsKeys.reservations,
      title: ReservationsLocalizations.name,
      counter: myReservations.length - cut,
      maxHeight: widget.maxHeight,
      actions: [
        NavigationAction(
          Icons.expand_more,
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => ReservationsPage()),
            );
          },
        ),
      ],
      children: [
        if (!loader.hasLoadedData || myReservations.isEmpty)
          EmptyList(title: ReservationsLocalizations.noReservations)
        else
          ...(myReservations.length > cut
                  ? myReservations.sublist(0, cut)
                  : myReservations)
              .map((reservation) => ReservationRow(
                    reservation: reservation,
                  ))
              .toList()
              .cast<PreferredSize>(),
      ],
    );
  }
}
