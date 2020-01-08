/// Times class
/// handles all unit times
class Times {
  /// Return the start and end of a unit
  static List<Duration> getUnitTimes(int unit, [bool short = false]) {
    Duration start;
    Duration end;
    if (short) {
      switch (unit) {
        case -1:
          start = Duration(); // 00:00
          end = Duration(); // 00:00
          break;
        case 0:
          start = Duration(hours: 08, minutes: 00); // 08:00
          end = Duration(hours: 08, minutes: 45); // 08:45
          break;
        case 1:
          start = Duration(hours: 08, minutes: 55); // 08:55
          end = Duration(hours: 09, minutes: 40); // 9:40
          break;
        case 2:
          start = Duration(hours: 10, minutes: 00); // 10:00
          end = Duration(hours: 10, minutes: 45); // 10:45
          break;
        case 3:
          start = Duration(hours: 10, minutes: 55); // 10:55
          end = Duration(hours: 11, minutes: 40); // 11:40
          break;
        case 4:
          start = Duration(hours: 12, minutes: 00); // 12:00
          end = Duration(hours: 12, minutes: 45); // 12:45
          break;
        case 5:
          start = Duration(hours: 12, minutes: 45); // 12:45
          end = Duration(hours: 13, minutes: 45); // 13:45
          break;
        case 6:
          start = Duration(hours: 13, minutes: 45); // 13:45
          end = Duration(hours: 14, minutes: 30); // 14:30
          break;
        case 7:
          start = Duration(hours: 14, minutes: 35); // 14:35
          end = Duration(hours: 15, minutes: 20); // 15:20
          break;
      }
    } else {
      switch (unit) {
        case -1:
          start = Duration(); // 00:00
          end = Duration(); // 00:00
          break;
        case 0:
          start = Duration(hours: 08, minutes: 00); // 08:00
          end = Duration(hours: 09, minutes: 00); // 09:00
          break;
        case 1:
          start = Duration(hours: 09, minutes: 10); // 09:10
          end = Duration(hours: 10, minutes: 10); // 10:10
          break;
        case 2:
          start = Duration(hours: 10, minutes: 30); // 10:30
          end = Duration(hours: 11, minutes: 30); // 11:30
          break;
        case 3:
          start = Duration(hours: 11, minutes: 40); // 11:40
          end = Duration(hours: 12, minutes: 40); // 12:40
          break;
        case 4:
          start = Duration(hours: 13, minutes: 00); // 13:00
          end = Duration(hours: 14, minutes: 00); // 14:00
          break;
        case 5:
          start = Duration(hours: 14, minutes: 00); // 14:00
          end = Duration(hours: 15, minutes: 00); // 15:00
          break;
        case 6:
          start = Duration(hours: 15, minutes: 00); // 15:00
          end = Duration(hours: 16, minutes: 00); // 16:00
          break;
        case 7:
          start = Duration(hours: 16, minutes: 05); // 16:05
          end = Duration(hours: 17, minutes: 05); // 17:05
          break;
      }
    }
    return [start, end];
  }
}
