import 'package:flutter/material.dart';
import 'package:ginko/utils/custom_circular_progress_indicator.dart';

// ignore: public_member_api_docs
Widget getLoadingPlaceholder(BuildContext context) => Container(
      height: 50,
      width: 50,
      child: Center(
        child: CustomCircularProgressIndicator(
          width: 20,
          height: 20,
        ),
      ),
    );
