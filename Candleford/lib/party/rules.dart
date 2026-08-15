/// The law of the party: with a year of d days and n guests, all
/// birthdays equally likely, the chance that no two share is
/// d(d - 1)...(d - n + 1) / d^n, and the chance that some two share is
/// one less that; it passes a half at 23 guests of a 365-day year, and
/// reaches one exactly at d + 1 guests, since d + 1 guests cannot all
/// have different days. Every fraction is exact, in big whole numbers.
class Rules {
  /// The days of the real year.
  static const year = 365;

  /// The months of a year.
  static const months = 12;

  /// The chance of a shared day among [n] guests of a [days]-day year,
  /// as (numerator, denominator), exact.
  static (BigInt, BigInt) shared(int days, int n) {
    final d = BigInt.from(days);
    var apart = BigInt.one;
    for (var i = 0; i < n; i++) {
      final left = days - i;
      if (left <= 0) {
        apart = BigInt.zero;
        break;
      }
      apart *= BigInt.from(left);
    }
    final all = d.pow(n);
    return (all - apart, all);
  }

  /// Whether the chance of a shared day among [n] guests is at least
  /// [num]/[den].
  static bool atLeast(int days, int n, int num, int den) {
    final (p, q) = shared(days, n);
    return p * BigInt.from(den) >= BigInt.from(num) * q;
  }

  /// Whether a shared day is certain among [n] guests.
  static bool certain(int days, int n) {
    final (p, q) = shared(days, n);
    return p == q;
  }

  /// The chance in a hundred, to [places] decimal places, exact then cut.
  static String inHundred(int days, int n, {int places = 2}) {
    final (p, q) = shared(days, n);
    final scale = BigInt.from(10).pow(places + 2);
    final scaled = p * scale ~/ q;
    final whole = scaled ~/ BigInt.from(10).pow(places);
    final rest = (scaled % BigInt.from(10).pow(places)).toString().padLeft(places, '0');
    return places == 0 ? '$whole' : '$whole.$rest';
  }

  /// The fewest guests whose shared-day chance is at least [num]/[den],
  /// searching up to days + 1.
  static int fewest(int days, int num, int den) {
    for (var n = 1; n <= days + 1; n++) {
      if (atLeast(days, n, num, den)) return n;
    }
    return days + 1;
  }

  /// The literal count: every way to give [n] guests a day of [days],
  /// and how many of those ways share a day, walked one by one. For the
  /// small years only.
  static (BigInt, BigInt) sharedByWalk(int days, int n) {
    var sharing = 0, all = 0;
    final day = List<int>.filled(n, 0);
    void walk(int i) {
      if (i == n) {
        all++;
        final seen = <int>{};
        for (final d in day) {
          if (!seen.add(d)) {
            sharing++;
            return;
          }
        }
        return;
      }
      for (var d = 0; d < days; d++) {
        day[i] = d;
        walk(i + 1);
      }
    }

    walk(0);
    return (BigInt.from(sharing), BigInt.from(all));
  }
}
