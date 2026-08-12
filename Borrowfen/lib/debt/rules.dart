/// The law of the ledger.
///
/// A village is houses joined by roads; each house holds pounds,
/// and a house in debt holds fewer than none. A lending house
/// sends one pound down every road it has; a borrowing house
/// pulls one pound up each. The village settles when no house is
/// in debt.
///
/// Whether a spread of debts can be settled at all is decided
/// three ways that share nothing: Dhar's burning reduces the
/// spread to its one tidy form and reads the verdict off the
/// first house; a census counts the tidy spreads and finds
/// exactly as many as the village has spanning trees; and a plain
/// search of lendings and borrowings either finds a settlement or
/// runs the bounds dry. The suite refuses the bake the moment any
/// two part ways.
class Rules {
  Rules(this.houses, this.roads) {
    degree = List.filled(houses, 0);
    beside = List.generate(houses, (_) => <int>[]);
    for (final (a, b) in roads) {
      degree[a]++;
      degree[b]++;
      beside[a].add(b);
      beside[b].add(a);
    }
  }

  final int houses;
  final List<(int, int)> roads;

  late final List<int> degree;
  late final List<List<int>> beside;

  /// Roads less houses, plus one: the number the total must reach
  /// for every class of spread to settle.
  int get genus => roads.length - houses + 1;

  /// One lending from [house].
  List<int> lend(List<int> pounds, int house) {
    final after = List.of(pounds);
    after[house] -= degree[house];
    for (final other in beside[house]) {
      after[other] += 1;
    }
    return after;
  }

  /// One borrowing at [house].
  List<int> borrow(List<int> pounds, int house) {
    final after = List.of(pounds);
    after[house] += degree[house];
    for (final other in beside[house]) {
      after[other] -= 1;
    }
    return after;
  }

  bool settled(List<int> pounds) =>
      pounds.every((held) => held >= 0);

  /// The spread's one tidy form: every house past the first out of
  /// debt and holding less than its roads, nothing left to fire.
  /// Dhar's burning, house nought as the bank.
  List<int> tidy(List<int> pounds) {
    final held = List.of(pounds);
    // First: clear the debt of every house past the bank, by
    // firing the bank and stabilising the rest.
    while ([for (var h = 1; h < houses; h++) held[h]]
        .any((p) => p < 0)) {
      held[0] -= degree[0];
      for (final other in beside[0]) {
        held[other] += 1;
      }
      var moved = true;
      while (moved) {
        moved = false;
        for (var house = 1; house < houses; house++) {
          if (held[house] >= degree[house]) {
            held[house] -= degree[house];
            for (final other in beside[house]) {
              held[other] += 1;
            }
            moved = true;
          }
        }
      }
    }
    // Then: burn from the bank; whatever will not catch, fires as
    // one, until the whole village burns.
    while (true) {
      final burnt = <int>{0};
      var spread = true;
      while (spread) {
        spread = false;
        for (var house = 1; house < houses; house++) {
          if (burnt.contains(house)) continue;
          final threats =
              beside[house].where(burnt.contains).length;
          if (held[house] < threats) {
            burnt.add(house);
            spread = true;
          }
        }
      }
      if (burnt.length == houses) return held;
      for (var house = 0; house < houses; house++) {
        if (burnt.contains(house)) continue;
        for (final other in beside[house]) {
          if (burnt.contains(other)) {
            held[house] -= 1;
            held[other] += 1;
          }
        }
      }
    }
  }

  /// The burning's verdict: a spread settles exactly when its tidy
  /// form leaves the bank out of debt.
  bool winnable(List<int> pounds) => tidy(pounds)[0] >= 0;

  /// Every tidy debt-free spread of the houses past the bank:
  /// the census the spanning trees must match.
  List<List<int>> superstables() {
    final found = <List<int>>[];
    final most = [for (var h = 1; h < houses; h++) degree[h]];
    final pick = List.filled(houses - 1, 0);
    void walk(int at) {
      if (at == pick.length) {
        final held = [0, ...pick];
        final burnt = <int>{0};
        var spread = true;
        while (spread) {
          spread = false;
          for (var house = 1; house < houses; house++) {
            if (burnt.contains(house)) continue;
            final threats =
                beside[house].where(burnt.contains).length;
            if (held[house] < threats) {
              burnt.add(house);
              spread = true;
            }
          }
        }
        if (burnt.length == houses) found.add(held);
        return;
      }
      for (var val = 0; val < most[at]; val++) {
        pick[at] = val;
        walk(at + 1);
      }
    }

    walk(0);
    return found;
  }

  /// The spanning trees, by Kirchhoff on the reduced Laplacian:
  /// integer cofactor arithmetic, no burning anywhere near it.
  int spanningTrees() {
    final side = houses - 1;
    final lap = List.generate(side, (_) => List.filled(side, 0));
    for (final (a, b) in roads) {
      if (a > 0) lap[a - 1][a - 1] += 1;
      if (b > 0) lap[b - 1][b - 1] += 1;
      if (a > 0 && b > 0) {
        lap[a - 1][b - 1] -= 1;
        lap[b - 1][a - 1] -= 1;
      }
    }
    return _det(lap);
  }

  int _det(List<List<int>> m) {
    final side = m.length;
    if (side == 1) return m[0][0];
    if (side == 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    var total = 0;
    for (var col = 0; col < side; col++) {
      final minor = [
        for (var row = 1; row < side; row++)
          [
            for (var c = 0; c < side; c++)
              if (c != col) m[row][c],
          ],
      ];
      final sign = col.isEven ? 1 : -1;
      total += sign * m[0][col] * _det(minor);
    }
    return total;
  }

  /// How many of the village's classes of spread settle at a
  /// total: the tidy spreads whose pounds fit inside it.
  int winnableClasses(int total) => superstables()
      .where((held) =>
          held.reduce((a, b) => a + b) <= total)
      .length;

  /// The third voice: a plain search of lendings and borrowings.
  /// Returns the fewest moves to a settlement, or null when the
  /// bounds run dry without one.
  int? fewest(List<int> pounds, {int cap = 9, int deep = 16}) {
    final start = pounds.join(',');
    final seen = <String>{start};
    var frontier = [pounds];
    for (var far = 0; far <= deep; far++) {
      final next = <List<int>>[];
      for (final held in frontier) {
        if (settled(held)) return far;
      }
      if (far == deep) break;
      for (final held in frontier) {
        for (var house = 0; house < houses; house++) {
          for (final move in [lend(held, house), borrow(held, house)]) {
            if (move.any((p) => p.abs() > cap)) continue;
            final key = move.join(',');
            if (seen.add(key)) next.add(move);
          }
        }
      }
      frontier = next;
    }
    return null;
  }

  /// The search's first step of a fewest settlement: the house and
  /// whether it lends, or null when no settlement is in reach.
  (int, bool)? firstMove(List<int> pounds) {
    final whole = fewest(pounds);
    if (whole == null || whole == 0) return null;
    for (var house = 0; house < houses; house++) {
      final lent = lend(pounds, house);
      final lentLeft = fewest(lent);
      if (lentLeft != null && lentLeft == whole - 1) {
        return (house, true);
      }
      final borrowed = borrow(pounds, house);
      final borrowedLeft = fewest(borrowed);
      if (borrowedLeft != null && borrowedLeft == whole - 1) {
        return (house, false);
      }
    }
    return null;
  }
}
