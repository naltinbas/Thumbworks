/// The law of the table.
///
/// Couples at a round table, wives already seated at every
/// other place, husbands to be seated between them, and one
/// rule: nobody sits beside their own partner. The menage
/// problem, 1891. Three couples manage it exactly one way,
/// four manage two, five manage thirteen; and two couples
/// never manage it, since a circle of four puts both wives
/// beside every husband, his own among them. Touchard's
/// arithmetic gives the same counts with no searching at all.
class Rules {
  Rules(this.couples);

  final int couples;

  /// The wives beside odd seat [gap]: the wife at its left and
  /// the wife round to its right.
  (int, int) besideGap(int gap) => (gap, (gap + 1) % couples);

  /// Whether a full seating breaks the rule anywhere: seat
  /// [gap] holds husband [seated[gap]], and the husband of
  /// wife w is w.
  List<int> quarrels(List<int?> seated) => [
        for (var gap = 0; gap < couples; gap++)
          if (seated[gap] != null &&
              (seated[gap] == besideGap(gap).$1 ||
                  seated[gap] == besideGap(gap).$2))
            gap,
      ];

  /// Whether a seating lands: every gap filled, no quarrels.
  bool lands(List<int?> seated) =>
      seated.every((husband) => husband != null) &&
      quarrels(seated).isEmpty;

  /// Every full seating, walked; calls [visit] with each.
  void seatings(void Function(List<int>) visit) {
    final seated = <int>[];
    final used = List.filled(couples, false);
    void place(int gap) {
      if (gap == couples) {
        visit(seated);
        return;
      }
      for (var husband = 0; husband < couples; husband++) {
        if (used[husband]) continue;
        used[husband] = true;
        seated.add(husband);
        place(gap + 1);
        seated.removeLast();
        used[husband] = false;
      }
    }

    place(0);
  }

  /// How many seatings land, by the sweep.
  int waysBySweep({(int, int)? given}) {
    var ways = 0;
    seatings((seated) {
      if (given != null && seated[given.$1] != given.$2) return;
      if (lands([...seated])) ways++;
    });
    return ways;
  }

  /// The same count by Touchard's arithmetic, no searching:
  /// alternating falls and rises over the couples parted.
  int waysByTouchard() {
    var total = 0.0;
    for (var k = 0; k <= couples; k++) {
      total += (k.isEven ? 1 : -1) *
          (2 * couples) /
          (2 * couples - k) *
          _choose(2 * couples - k, k) *
          _factorial(couples - k);
    }
    return total.round();
  }

  int _choose(int n, int k) {
    var top = 1;
    var bottom = 1;
    for (var at = 0; at < k; at++) {
      top *= n - at;
      bottom *= at + 1;
    }
    return top ~/ bottom;
  }

  int _factorial(int n) => n <= 1 ? 1 : n * _factorial(n - 1);

  /// One landing seating, honouring [given], or null: drives
  /// the show-me.
  List<int>? landing({(int, int)? given}) {
    List<int>? found;
    seatings((seated) {
      if (found != null) return;
      if (given != null && seated[given.$1] != given.$2) return;
      if (lands([...seated])) found = List.of(seated);
    });
    return found;
  }

  /// The turn of a full seating: when every husband sits the
  /// same count of gaps round from his own wife's gap, that
  /// count, and null when the table does not turn as one.
  int? turnOf(List<int> seated) {
    int? turn;
    for (var gap = 0; gap < couples; gap++) {
      final step = (gap - seated[gap]) % couples;
      if (turn == null) {
        turn = step;
      } else if (step != turn) {
        return null;
      }
    }
    return turn;
  }

  /// The whole-table turn by [step]: husband w in gap w + step.
  List<int> turned(int step) => [
        for (var gap = 0; gap < couples; gap++)
          (gap - step) % couples,
      ];

  /// The steps whose whole-table turn lands, built and read
  /// with no sweeping: the seat beside a wife is her own gap
  /// or the one before, so every other step lands.
  List<int> turnings() => [
        for (var step = 0; step < couples; step++)
          if (lands(turned(step))) step,
      ];

  /// How many landings turn the whole table, by the sweep.
  int turnsBySweep({(int, int)? given}) {
    var turns = 0;
    seatings((seated) {
      if (given != null && seated[given.$1] != given.$2) return;
      if (lands([...seated]) && turnOf(seated) != null) turns++;
    });
    return turns;
  }

  /// The seating read in the mirror: the table reflected
  /// through wife 0's chair, so wife w becomes wife -w and gap
  /// g becomes the gap across from it.
  List<int> mirror(List<int> seated) {
    final mirrored = List.filled(couples, 0);
    for (var gap = 0; gap < couples; gap++) {
      mirrored[(couples - 1 - gap) % couples] =
          (couples - seated[gap]) % couples;
    }
    return mirrored;
  }

  /// The two counts held together at every size shipped: true
  /// when nothing breaks.
  static bool lawsHold() {
    for (final couples in [2, 3, 4, 5]) {
      final rules = Rules(couples);
      if (rules.waysBySweep() != rules.waysByTouchard()) {
        return false;
      }
    }
    return true;
  }
}
