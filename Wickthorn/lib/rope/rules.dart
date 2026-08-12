/// The law of the green.
///
/// Lanterns stand on a village green, and ropes are strung three
/// lanterns to a rope. The asking is always the same: string
/// ropes until every pair of lanterns shares exactly one.
///
/// Whether a green can close is known three ways that share
/// nothing: the pair ledger counts every pair covered and cries
/// at a doubling; the lantern arithmetic divides, since a lantern
/// among n must share a rope with n - 1 others, two at a time,
/// and (n - 1) / 2 must come out whole; and the search strings
/// every roping to its end and counts the closings. The suite
/// refuses the bake the moment any two part ways.
class Rules {
  Rules(this.lanterns);

  final int lanterns;

  /// Every pair the green must cover.
  int get pairsNeeded => lanterns * (lanterns - 1) ~/ 2;

  /// The ropes a closed green holds: a third of the pairs.
  int get ropesNeeded => pairsNeeded ~/ 3;

  /// Whether the pair count even divides by three.
  bool get pairsDivide => pairsNeeded % 3 == 0;

  /// The ropes each lantern must stand in, twice the true share:
  /// kept doubled so it stays a whole number either way.
  int get twiceShare => lanterns - 1;

  /// Whether the lantern arithmetic comes out whole: each lantern
  /// shares a rope with n - 1 others, two at a time.
  bool get shareDivides => twiceShare.isEven;

  /// The pairs a roping covers, each with how many ropes cover it.
  Map<(int, int), int> ledger(List<(int, int, int)> ropes) {
    final covered = <(int, int), int>{};
    for (final (a, b, c) in ropes) {
      for (final pair in [(a, b), (a, c), (b, c)]) {
        final sorted = pair.$1 < pair.$2
            ? pair
            : (pair.$2, pair.$1);
        covered[sorted] = (covered[sorted] ?? 0) + 1;
      }
    }
    return covered;
  }

  /// Pairs covered exactly once so far.
  int coveredOnce(List<(int, int, int)> ropes) =>
      ledger(ropes).values.where((held) => held == 1).length;

  /// Pairs covered twice or more: the clashes.
  List<(int, int)> clashes(List<(int, int, int)> ropes) => [
        for (final held in ledger(ropes).entries)
          if (held.value > 1) held.key,
      ];

  /// Whether the green stands closed: every pair exactly once.
  bool closed(List<(int, int, int)> ropes) =>
      ropes.length == ropesNeeded &&
      clashes(ropes).isEmpty &&
      coveredOnce(ropes) == pairsNeeded;

  /// How many ropes each lantern stands in.
  List<int> standings(List<(int, int, int)> ropes) {
    final stood = List.filled(lanterns, 0);
    for (final (a, b, c) in ropes) {
      stood[a]++;
      stood[b]++;
      stood[c]++;
    }
    return stood;
  }

  /// Every closing of the green that extends [given], counted by
  /// the search: pair-led backtracking, first uncovered pair
  /// branched on.
  int closings(List<(int, int, int)> given) {
    if (!pairsDivide) return 0;
    final covered = <(int, int), bool>{};
    for (final rope in given) {
      for (final pair in _pairsOf(rope)) {
        if (covered.containsKey(pair)) return 0;
        covered[pair] = true;
      }
    }
    var found = 0;
    void walk() {
      if (covered.length == pairsNeeded) {
        found++;
        return;
      }
      (int, int)? first;
      for (var a = 0; a < lanterns && first == null; a++) {
        for (var b = a + 1; b < lanterns; b++) {
          if (!covered.containsKey((a, b))) {
            first = (a, b);
            break;
          }
        }
      }
      final (a, b) = first!;
      for (var c = 0; c < lanterns; c++) {
        if (c == a || c == b) continue;
        final rope = _sorted(a, b, c);
        final pairs = _pairsOf(rope);
        if (pairs
            .where((pair) => pair != (a, b))
            .any(covered.containsKey)) {
          continue;
        }
        for (final pair in pairs) {
          covered[pair] = true;
        }
        walk();
        for (final pair in pairs) {
          covered.remove(pair);
        }
      }
    }

    walk();
    return found;
  }

  /// One closing extending [given], or null: the search stopped
  /// at its first find.
  List<(int, int, int)>? closing(List<(int, int, int)> given) {
    if (!pairsDivide) return null;
    final covered = <(int, int), bool>{};
    for (final rope in given) {
      for (final pair in _pairsOf(rope)) {
        if (covered.containsKey(pair)) return null;
        covered[pair] = true;
      }
    }
    final strung = List.of(given);
    bool walk() {
      if (covered.length == pairsNeeded) return true;
      (int, int)? first;
      for (var a = 0; a < lanterns && first == null; a++) {
        for (var b = a + 1; b < lanterns; b++) {
          if (!covered.containsKey((a, b))) {
            first = (a, b);
            break;
          }
        }
      }
      final (a, b) = first!;
      for (var c = 0; c < lanterns; c++) {
        if (c == a || c == b) continue;
        final rope = _sorted(a, b, c);
        final pairs = _pairsOf(rope);
        if (pairs
            .where((pair) => pair != (a, b))
            .any(covered.containsKey)) {
          continue;
        }
        for (final pair in pairs) {
          covered[pair] = true;
        }
        strung.add(rope);
        if (walk()) return true;
        strung.removeLast();
        for (final pair in pairs) {
          covered.remove(pair);
        }
      }
      return false;
    }

    return walk() ? strung : null;
  }

  static (int, int, int) _sorted(int a, int b, int c) {
    final three = [a, b, c]..sort();
    return (three[0], three[1], three[2]);
  }

  static List<(int, int)> _pairsOf((int, int, int) rope) {
    final (a, b, c) = rope;
    return [(a, b), (a, c), (b, c)];
  }
}
