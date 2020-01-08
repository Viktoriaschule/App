import 'dart:io' as io show Platform;

import 'package:ginko/plugins/platform/platform_base.dart';

/// Platform class
/// handles platform on mobile and desktop devices
class Platform extends PlatformBase {
  // ignore: public_member_api_docs
  Platform()
      : super(
          isLinux: io.Platform.isLinux,
          isWindows: io.Platform.isWindows,
          isMacOS: io.Platform.isMacOS,
          isAndroid: io.Platform.isAndroid,
          isIOS: io.Platform.isIOS,
        );
}
