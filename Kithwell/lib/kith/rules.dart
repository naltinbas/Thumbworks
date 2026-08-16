import 'frac.dart';

/// Six people at the fair, and who knows whom: a plan of friendships is
/// a set of pairs, told as a mask of fifteen bits. Count everyone's
/// friends and take the average; then ask everyone's friends how many
/// friends they have, counting a person once for every friend who
/// names them, and take that average: the second is never below the
/// first. This is the friendship paradox, Feld's of 1991, and the reason
/// is that a spread of numbers has an average of squares at least the
/// square of the average.
class Rules {
  static const people = 6;

  static const names = ['Ann', 'Bess', 'Cal', 'Dot', 'Ed', 'Fay'];

  /// The pairs that could be friends, the lower first.
  static const pairs = <(int, int)>[
    (0, 1), (0, 2), (0, 3), (0, 4), (0, 5),
    (1, 2), (1, 3), (1, 4), (1, 5),
    (2, 3), (2, 4), (2, 5),
    (3, 4), (3, 5),
    (4, 5),
  ];

  static int get plans => 1 << pairs.length;

  static int pairOf(int a, int b) {
    final lo = a < b ? a : b, hi = a < b ? b : a;
    for (var i = 0; i < pairs.length; i++) {
      if (pairs[i] == (lo, hi)) return i;
    }
    return -1;
  }

  static bool friends(int mask, int a, int b) => a != b && mask & (1 << pairOf(a, b)) != 0;

  static int toggled(int mask, int a, int b) => mask ^ (1 << pairOf(a, b));

  static int friendships(int mask) {
    var n = 0;
    for (var i = 0; i < pairs.length; i++) {
      if (mask & (1 << i) != 0) n++;
    }
    return n;
  }

  static List<(int, int)> pairsOf(int mask) => [for (var i = 0; i < pairs.length; i++) if (mask & (1 << i) != 0) pairs[i]];

  /// How many friends person [v] has.
  static int degree(int mask, int v) {
    var n = 0;
    for (var u = 0; u < people; u++) {
      if (friends(mask, u, v)) n++;
    }
    return n;
  }

  static List<int> degrees(int mask) => [for (var v = 0; v < people; v++) degree(mask, v)];

  /// The average number of friends a person has.
  static Frac average(int mask) => Frac.of(degrees(mask).fold(0, (a, b) => a + b), people);

  /// The friends' average, the first voice: every friendship named from
  /// both ends, the named friend's count of friends taken down each
  /// time, and the lot averaged; null when nobody has a friend.
  static Frac? friendsAverage(int mask) {
    var namings = 0, total = 0;
    for (var v = 0; v < people; v++) {
      for (var u = 0; u < people; u++) {
        if (friends(mask, v, u)) {
          namings++;
          total += degree(mask, u);
        }
      }
    }
    return namings == 0 ? null : Frac.of(total, namings);
  }

  /// The friends' average by the squares, the second voice: the sum of
  /// the squares of everyone's count over the sum of the counts, which
  /// is the average plus the spread of the counts over the average.
  static Frac? friendsAverageBySquares(int mask) {
    final d = degrees(mask);
    final sum = d.fold(0, (a, b) => a + b);
    if (sum == 0) return null;
    return Frac.of(d.fold(0, (a, b) => a + b * b), sum);
  }

  /// The gap between the friends' average and the average, or null.
  static Frac? gap(int mask) {
    final f = friendsAverage(mask);
    return f == null ? null : f - average(mask);
  }

  /// The spread of the counts: the average of their squares less the
  /// square of their average, never below nought.
  static Frac spread(int mask) {
    final d = degrees(mask);
    final mean = average(mask);
    var out = Frac.zero;
    for (final x in d) {
      out = out + (Frac.of(x) - mean) * (Frac.of(x) - mean);
    }
    return out / Frac.of(people);
  }

  /// The average, person by person, of the average count among a
  /// person's own friends, over those with a friend at all: the
  /// person-by-person version, which need not hold, and the game says
  /// how often it fails.
  static Frac? personByPerson(int mask) {
    var out = Frac.zero;
    var counted = 0;
    for (var v = 0; v < people; v++) {
      final d = degree(mask, v);
      if (d == 0) continue;
      var total = 0;
      for (var u = 0; u < people; u++) {
        if (friends(mask, v, u)) total += degree(mask, u);
      }
      out = out + Frac.of(total, d);
      counted++;
    }
    return counted == 0 ? null : out / Frac.of(counted);
  }

  static String tell(int mask) => pairsOf(mask).map((p) => '${names[p.$1]}-${names[p.$2]}').join(', ');

  static int planOf(String told) {
    var mask = 0;
    for (final part in told.split(',')) {
      final t = part.trim();
      if (t.isEmpty) continue;
      final ends = t.split('-');
      mask |= 1 << pairOf(names.indexOf(ends[0]), names.indexOf(ends[1]));
    }
    return mask;
  }
}

/// A number told with its whole part: '1 1/3', '2', '1/2'.
String tellFrac(Frac f) {
  final whole = f.n ~/ f.d;
  final rest = f - Frac(whole, BigInt.one);
  if (rest == Frac.zero) return '$whole';
  return whole == BigInt.zero ? '$rest' : '$whole $rest';
}
