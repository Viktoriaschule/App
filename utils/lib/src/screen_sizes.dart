/// Get the screen size of the device
ScreenSize getScreenSize(double width) {
  if (width < 620) {
    return ScreenSize.small;
  } else if (width < 1560) {
    return ScreenSize.middle;
  } else {
    return ScreenSize.big;
  }
}

/// ScreenSize enum
/// describes the size of the device screen
enum ScreenSize {
  // ignore: public_member_api_docs
  small,
  // ignore: public_member_api_docs
  middle,
  // ignore: public_member_api_docs
  big,
}
