/// PlatformBase class
/// describes the abstract layer of platform
abstract class PlatformBase {
  // ignore: public_member_api_docs
  const PlatformBase({
    this.isLinux = false,
    this.isMacOS = false,
    this.isWindows = false,
    this.isAndroid = false,
    this.isIOS = false,
    this.isWeb = false,
  });

  // ignore: public_member_api_docs
  final bool isLinux;

  // ignore: public_member_api_docs
  final bool isMacOS;

  // ignore: public_member_api_docs
  final bool isWindows;

  // ignore: public_member_api_docs
  final bool isAndroid;

  // ignore: public_member_api_docs
  final bool isIOS;

  // ignore: public_member_api_docs
  final bool isWeb;

  // ignore: public_member_api_docs
  bool get isDesktop => isLinux || isWindows || isMacOS;

  // ignore: public_member_api_docs
  bool get isMobile => isAndroid || isIOS;

  /// Get the name of the platform
  String get platformName {
    if (isLinux) {
      return 'linux';
    } else if (isMacOS) {
      return 'macos';
    } else if (isWindows) {
      return 'windows';
    } else if (isAndroid) {
      return 'android';
    } else if (isIOS) {
      return 'ios';
    } else if (isWeb) {
      return 'web';
    }
    return 'unknown';
  }
}
