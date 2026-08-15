/// The law of the almanac: a year begins on some day of the week and
/// is common or leap, fourteen kinds in all, and the thirteenth of each
/// month falls where the days before it put it.
class Rules {
  const Rules();

  static const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  static const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  static const common = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  static const leap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  static const friday = 4;

  /// The day of the week, nought for Monday, of the thirteenth of each
  /// month in a year that begins on [start] and is leap or not.
  static List<int> thirteenths(int start, bool isLeap) {
    final lengths = isLeap ? leap : common;
    final out = <int>[];
    var first = start;
    for (var m = 0; m < 12; m++) {
      out.add((first + 12) % 7);
      first = (first + lengths[m]) % 7;
    }
    return out;
  }

  /// The months whose thirteenth is a Friday.
  static List<int> fridays(int start, bool isLeap) => [
        for (var m = 0; m < 12; m++)
          if (thirteenths(start, isLeap)[m] == friday) m,
      ];

  /// The offsets of the thirteenths from the first of the year, by the
  /// week: the days of the year before each month, mod seven.
  static List<int> offsets(bool isLeap) {
    final lengths = isLeap ? leap : common;
    final out = <int>[];
    var d = 0;
    for (var m = 0; m < 12; m++) {
      out.add(d % 7);
      d += lengths[m];
    }
    return out;
  }

  /// The fourteen kinds of year, (start, leap), and the Fridays of each.
  static List<((int, bool), List<int>)> get kinds => [
        for (final isLeap in [false, true])
          for (var s = 0; s < 7; s++) ((s, isLeap), fridays(s, isLeap)),
      ];

  /// The kinds meeting an ask, and all: (meeting, all).
  static (int, int) sweep(bool Function(List<int> fridays) ask) {
    var meeting = 0;
    for (final (_, f) in kinds) {
      if (ask(f)) meeting++;
    }
    return (meeting, kinds.length);
  }

  /// A real year read by the phone's own calendar: the day of the week
  /// of the first of January, whether it is leap, and its Fridays the
  /// thirteenth, month by month.
  static ((int, bool), List<int>) real(int year) {
    final first = DateTime(year, 1, 1).weekday - 1;
    final isLeap = DateTime(year, 3, 0).day == 29;
    final fridays = [
      for (var m = 1; m <= 12; m++)
        if (DateTime(year, m, 13).weekday == DateTime.friday) m - 1,
    ];
    return ((first, isLeap), fridays);
  }
}
