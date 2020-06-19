// ignore: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:reservations/reservations.dart';
import 'package:reservations/src/reservations_dialog_new.dart';
import 'package:reservations/src/reservations_events.dart';
import 'package:reservations/src/reservations_keys.dart';
import 'package:reservations/src/reservations_localizations.dart';
import 'package:reservations/src/reservations_row.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

/// The reservation management frontend
class ReservationsPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ReservationsPage({Key key}) : super(key: key);

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends Interactor<ReservationsPage>
    with TickerProviderStateMixin {
  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<ReservationsUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    final loader = ReservationsWidget.of(context).feature.loader;
    final subjects = loader.timetableManagement.data;
    final reservations = loader.data?.reservations;
    final count = reservations.length;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        CustomAppBar(
          title: ReservationsLocalizations.name,
          sliver: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => showDialog(
                context: context,
                child: NewReservationDialog(
                  onFinished: () => setState(() => null),
                ),
              ),
            )
          ],
          loadingKeys: const [
            ReservationsKeys.reservations,
            ReservationsKeys.reservationList,
            ReservationsKeys.reservationGroups,
            ReservationsKeys.reservationTimetable,
          ],
        ),
      ],
      body: CustomRefreshIndicator(
        loadOnline: () => loader.loadOnline(context, force: true),
        child: count > 0
            ? Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: count,
                  itemBuilder: (context, index) => SizeLimit(
                    child: ReservationRow(
                      reservation: reservations[index],
                      subject: subjects
                          .getSubjectWithId(reservations[index].timetableID),
                    ),
                  ),
                ),
              )
            : EmptyList(title: ReservationsLocalizations.noReservations),
      ),
    );
  }
}
