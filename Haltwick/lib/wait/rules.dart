import 'frac.dart';

/// Three buses an hour, and the gaps between them, which add to sixty
/// minutes. A passenger comes to the stop at any minute of the hour,
/// each as likely, and waits for the next bus. The average wait is
/// half a gap less half a minute when the gaps are equal, and longer
/// whenever they are not: this is the waiting-time paradox, Feller's,
/// and it never runs the other way, since the average of squares is
/// never below the square of the average.
class Rules {
  static const hour = 60, buses = 3;

  /// Every timetable: three gaps of a minute or more adding to the hour,
  /// in order, (1, 1, 58) first.
  static List<List<int>> get timetables => [
        for (var a = 1; a <= hour - 2; a++)
          for (var b = 1; a + b <= hour - 1; b++) [a, b, hour - a - b],
      ];

  static int get count => timetables.length;

  static bool valid(List<int> gaps) => gaps.length == buses && gaps.every((g) => g >= 1) && gaps.fold(0, (a, b) => a + b) == hour;

  /// The average wait by the gaps, the first voice: within a gap of g
  /// minutes the waits are g - 1 down to 0, adding to g(g - 1)/2, and
  /// the sixty minutes share the lot.
  static Frac waitByGaps(List<int> gaps) => Frac.of(gaps.fold(0, (a, g) => a + g * (g - 1)), 2 * hour);

  /// The minutes the buses come at, from nought.
  static List<int> busesAt(List<int> gaps) {
    final at = <int>[0];
    for (var i = 0; i < gaps.length - 1; i++) {
      at.add(at.last + gaps[i]);
    }
    return at;
  }

  /// How long a passenger arriving at minute [t] waits.
  static int waitAt(List<int> gaps, int t) {
    final at = busesAt(gaps);
    var best = hour;
    for (final b in at) {
      final w = (b - t) % hour;
      if (w < best) best = w;
    }
    return best;
  }

  /// The average wait minute by minute, the second voice: every minute
  /// of the hour taken, its wait found, and the sixty averaged.
  static Frac waitByMinutes(List<int> gaps) {
    var total = 0;
    for (var t = 0; t < hour; t++) {
      total += waitAt(gaps, t);
    }
    return Frac.of(total, hour);
  }

  /// The fair wait: what equal gaps give, half a gap less half a minute.
  static Frac get fairWait => Frac.of(hour ~/ buses - 1, 2);

  /// The longest wait anyone has: the longest gap less one.
  static int longest(List<int> gaps) => gaps.reduce((a, b) => a > b ? a : b) - 1;

  /// A number of minutes told: '9 1/2', '10', '11 1/6'.
  static String tell(Frac f) {
    final whole = f.n ~/ f.d;
    final rest = f - Frac(whole, BigInt.one);
    if (rest == Frac.zero) return '$whole';
    return whole == BigInt.zero ? '$rest' : '$whole $rest';
  }

  static String tellGaps(List<int> gaps) => '${gaps[0]}, ${gaps[1]} and ${gaps[2]}';
}
