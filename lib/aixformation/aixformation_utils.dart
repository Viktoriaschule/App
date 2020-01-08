import 'package:flutter/material.dart';

// ignore: public_member_api_docs
Widget getLoadingPlaceholder(BuildContext context) => Container(
      height: 56,
      width: 56,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
