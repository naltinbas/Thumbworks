/// The law of the book.
///
/// A day of hirings, each wanting the hall from a start to an end.
/// Two hirings clash when their hours overlap; ends may meet starts.
/// The book is full when as many hirings as the day allows stand
/// together, none clashing.
///
/// How many that is is known three ways that share nothing: the
/// early-finish rule fills a book greedily; a sweep tries every
/// choice of hirings there is; and a handful of piercing o'clocks,
/// one inside every hiring, shows no fuller book can stand.
class Rules {
  Rules(this.starts, this.ends);

  final List<int> starts;
  final List<int> ends;

  int get hirings => starts.length;

  /// Whether two hirings clash: open intervals, so an end may meet a
  /// start.
  bool clash(int one, int other) =>
      one != other &&
      starts[one] < ends[other] &&
      starts[other] < ends[one];

  /// Whether a choice of hirings stands without a clash.
  bool stands(int chosen) {
    for (var one = 0; one < hirings; one++) {
      if (chosen & (1 << one) == 0) continue;
      for (var other = one + 1; other < hirings; other++) {
        if (chosen & (1 << other) == 0) continue;
        if (clash(one, other)) return false;
      }
    }
    return true;
  }

  static int weigh(int mask) {
    var count = 0;
    var bits = mask;
    while (bits != 0) {
      bits &= bits - 1;
      count++;
    }
    return count;
  }

  /// The fullest any book can be, swept over every choice.
  int fullestBySweep() {
    var best = 0;
    for (var chosen = 0; chosen < (1 << hirings); chosen++) {
      if (stands(chosen)) {
        final count = weigh(chosen);
        if (count > best) best = count;
      }
    }
    return best;
  }

  /// How many choices reach the fullest.
  int fullestWays() {
    final best = fullestBySweep();
    var ways = 0;
    for (var chosen = 0; chosen < (1 << hirings); chosen++) {
      if (stands(chosen) && weigh(chosen) == best) ways++;
    }
    return ways;
  }

  /// The early-finish rule: take whatever ends soonest and does not
  /// clash with what is taken, until nothing is left. Knows nothing of
  /// sweeps.
  int byEarlyFinish() {
    final order = [for (var hiring = 0; hiring < hirings; hiring++) hiring]
      ..sort((one, other) => ends[one].compareTo(ends[other]));
    var taken = 0;
    for (final hiring in order) {
      var fine = true;
      for (var held = 0; held < hirings; held++) {
        if (taken & (1 << held) != 0 && clash(hiring, held)) {
          fine = false;
          break;
        }
      }
      if (fine) taken |= 1 << hiring;
    }
    return taken;
  }

  /// The early-start rule, for the trap: take whatever starts soonest.
  int byEarlyStart() {
    final order = [for (var hiring = 0; hiring < hirings; hiring++) hiring]
      ..sort((one, other) => starts[one].compareTo(starts[other]));
    var taken = 0;
    for (final hiring in order) {
      var fine = true;
      for (var held = 0; held < hirings; held++) {
        if (taken & (1 << held) != 0 && clash(hiring, held)) {
          fine = false;
          break;
        }
      }
      if (fine) taken |= 1 << hiring;
    }
    return taken;
  }

  /// The piercing o'clocks: walking the hirings by end, a clock is
  /// struck at each end not already inside every unpierced hiring...
  /// rather: at the end of the first unpierced hiring, again and
  /// again. Every hiring contains one strike, and two hirings sharing
  /// a strike clash, so no book holds more hirings than strikes.
  List<int> piercing() {
    final order = [for (var hiring = 0; hiring < hirings; hiring++) hiring]
      ..sort((one, other) => ends[one].compareTo(ends[other]));
    final strikes = <int>[];
    final pierced = List<bool>.filled(hirings, false);
    for (final hiring in order) {
      if (pierced[hiring]) continue;
      // Strike just inside the end: every hiring holding this moment
      // is pierced. Ends are exclusive, so the moment is end minus a
      // half; kept as the end itself with containment start < t <=
      // end checked half-open below.
      final strike = ends[hiring];
      strikes.add(strike);
      for (var other = 0; other < hirings; other++) {
        if (starts[other] < strike && strike <= ends[other]) {
          pierced[other] = true;
        }
      }
    }
    return strikes;
  }

  /// Whether every hiring holds one of the strikes.
  bool pierced(List<int> strikes) {
    for (var hiring = 0; hiring < hirings; hiring++) {
      var held = false;
      for (final strike in strikes) {
        if (starts[hiring] < strike && strike <= ends[hiring]) {
          held = true;
          break;
        }
      }
      if (!held) return false;
    }
    return true;
  }
}
