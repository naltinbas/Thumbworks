/// A share: cured of seen, kept as whole numbers.
typedef Share = (int, int);

/// The law of the garden: two healers, Ash and Birch, two seasons,
/// spring and autumn, and each healer's cure in each season a fixed
/// share of those seen: Ash cures nine in ten in spring and three in
/// ten in autumn, Birch eight in ten and two in ten, so Ash cures the
/// bigger share in both seasons. Each healer sees ten to fifty patients
/// a season, in tens, and the year's share is the cured of the seen
/// over both seasons.
class Rules {
  const Rules();

  static const healers = ['Ash', 'Birch'];
  static const seasons = ['spring', 'autumn'];

  /// Cures in ten, healer by season.
  static const cureInTen = [
    [9, 3],
    [8, 2],
  ];

  static const loads = [10, 20, 30, 40, 50];

  /// Cured of seen for healer [h] in season [s] with [seen] patients.
  static Share season(int h, int s, int seen) => (cureInTen[h][s] * seen ~/ 10, seen);

  /// Cured of seen for healer [h] over the year, seeing [spring] and
  /// [autumn] patients.
  static Share year(int h, int spring, int autumn) {
    final (c1, n1) = season(h, 0, spring);
    final (c2, n2) = season(h, 1, autumn);
    return (c1 + c2, n1 + n2);
  }

  /// Compares two shares: negative when [a] is the smaller.
  static int compare(Share a, Share b) => (a.$1 * b.$2).compareTo(b.$1 * a.$2);

  /// The share as parts in a hundred, rounded.
  static int inHundred(Share a) => (a.$1 * 100 + a.$2 ~/ 2) ~/ a.$2;

  /// Every setting of the four loads: (Ash spring, Ash autumn, Birch
  /// spring, Birch autumn), and those meeting [ask]: (meeting, all).
  static (int, int) sweep(bool Function(int, int, int, int) ask) {
    var meeting = 0, all = 0;
    for (final a1 in loads) {
      for (final a2 in loads) {
        for (final b1 in loads) {
          for (final b2 in loads) {
            all++;
            if (ask(a1, a2, b1, b2)) meeting++;
          }
        }
      }
    }
    return (meeting, all);
  }

  /// Every setting with the loads alike for both healers, season by
  /// season, and those meeting [ask]: (meeting, all).
  static (int, int) sweepEqual(bool Function(int, int, int, int) ask) {
    var meeting = 0, all = 0;
    for (final s in loads) {
      for (final a in loads) {
        all++;
        if (ask(s, a, s, a)) meeting++;
      }
    }
    return (meeting, all);
  }

  /// The first setting meeting [ask], in the sweep's order, or null.
  static (int, int, int, int)? first(bool Function(int, int, int, int) ask) {
    for (final a1 in loads) {
      for (final a2 in loads) {
        for (final b1 in loads) {
          for (final b2 in loads) {
            if (ask(a1, a2, b1, b2)) return (a1, a2, b1, b2);
          }
        }
      }
    }
    return null;
  }
}
