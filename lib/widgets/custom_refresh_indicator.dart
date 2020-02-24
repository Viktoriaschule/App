import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class CustomRefreshIndicator extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomRefreshIndicator({
    @required this.child,
    @required this.loadOnline,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Future<StatusCodes> Function() loadOnline;

  // ignore: public_member_api_docs
  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async {
          // ignore: unawaited_futures
          loadOnline().then((status) {
            if (status != StatusCodes.success) {
              final msg = status == StatusCodes.offline
                  ? 'Du bist offline'
                  : 'Verbindung zum Server fehlgeschlagen';
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () => null,
                  ),
                ),
              );
            }
          });
          await Future.delayed(Duration(milliseconds: 200));
        },
        child: child,
      );
}
