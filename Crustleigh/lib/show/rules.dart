/// The law of the show: three judges each rank the pies, first to last,
/// and one pie beats another when more judges rank it above. With three
/// judges every pair is decided, two to one or three to nothing, and the
/// majority can run in a ring, apple over bramble, bramble over cherry,
/// cherry over apple, which is Condorcet's paradox: each judge's ranking
/// runs straight, and the show's does not.
///
/// A pie that beats every other is a Condorcet winner. With three pies
/// it is always somebody's first choice: were it first on no ballot, on
/// each ballot it would lie under one of the other two, so the ballots
/// ranking it over the first other and those ranking it over the second
/// would come to three at most between them, and beating both takes two
/// of each, four. With four pies the modest winner happens.
class Rules {
  static const judges = 3;

  static const pieNames = ['apple', 'bramble', 'cherry', 'damson'];

  /// Every ranking of [pies] pies, as lists first to last.
  static List<List<int>> rankings(int pies) {
    final out = <List<int>>[];
    void grow(List<int> so, List<int> left) {
      if (left.isEmpty) {
        out.add(List.of(so));
        return;
      }
      for (final p in left) {
        grow([...so, p], left.where((q) => q != p).toList());
      }
    }

    grow([], List.generate(pies, (i) => i));
    return out;
  }

  /// Whether [ballot] ranks pie [a] above pie [b].
  static bool above(List<int> ballot, int a, int b) => ballot.indexOf(a) < ballot.indexOf(b);

  /// How many of [profile]'s ballots rank [a] above [b].
  static int count(List<List<int>> profile, int a, int b) => profile.where((ballot) => above(ballot, a, b)).length;

  /// Whether pie [a] beats pie [b] in the show, more judges ranking it above.
  static bool beats(List<List<int>> profile, int a, int b) => count(profile, a, b) * 2 > profile.length;

  /// The pie that beats every other, or null.
  static int? condorcetWinner(List<List<int>> profile, int pies) {
    for (var a = 0; a < pies; a++) {
      var all = true;
      for (var b = 0; b < pies && all; b++) {
        if (a != b && !beats(profile, a, b)) all = false;
      }
      if (all) return a;
    }
    return null;
  }

  /// The pies that are first on some ballot.
  static Set<int> firsts(List<List<int>> profile) => profile.map((b) => b.first).toSet();

  /// Whether the majority runs in a ring through all the pies, in some
  /// order round: each pie beats the next and the last beats the first.
  static bool ring(List<List<int>> profile, int pies) {
    for (final order in rankings(pies)) {
      if (order.first != 0) continue;
      var round = true;
      for (var i = 0; i < pies && round; i++) {
        if (!beats(profile, order[i], order[(i + 1) % pies])) round = false;
      }
      if (round) return true;
    }
    return false;
  }

  /// The ring's order, apple first, or null: the pies each beating the next.
  static List<int>? ringOrder(List<List<int>> profile, int pies) {
    for (final order in rankings(pies)) {
      if (order.first != 0) continue;
      var round = true;
      for (var i = 0; i < pies && round; i++) {
        if (!beats(profile, order[i], order[(i + 1) % pies])) round = false;
      }
      if (round) return order;
    }
    return null;
  }

  /// The points, one for each pie ranked below, summed over the ballots.
  static List<int> points(List<List<int>> profile, int pies) => List.generate(pies, (a) => profile.fold(0, (sum, b) => sum + (pies - 1 - b.indexOf(a))));

  /// Every profile of three ballots over [pies] pies, asked, and how many
  /// met the ask, with the count of profiles.
  static (int, int) sweep(int pies, bool Function(List<List<int>>) ask) {
    final all = rankings(pies);
    var met = 0, total = 0;
    for (final a in all) {
      for (final b in all) {
        for (final c in all) {
          total++;
          if (ask([a, b, c])) met++;
        }
      }
    }
    return (met, total);
  }

  /// The same count read the other way: over the ballots as a bag, each
  /// bag counted as many ways as its ballots can be dealt to the three
  /// judges, 6, 3 or 1.
  static (int, int) sweepBags(int pies, bool Function(List<List<int>>) ask) {
    final all = rankings(pies);
    var met = 0, total = 0;
    for (var i = 0; i < all.length; i++) {
      for (var j = i; j < all.length; j++) {
        for (var k = j; k < all.length; k++) {
          final ways = i == j && j == k ? 1 : (i == j || j == k) ? 3 : 6;
          total += ways;
          if (ask([all[i], all[j], all[k]])) met += ways;
        }
      }
    }
    return (met, total);
  }

  /// The first profile meeting [ask], in the sweep's order, or null.
  static List<List<int>>? first(int pies, bool Function(List<List<int>>) ask) {
    final all = rankings(pies);
    for (final a in all) {
      for (final b in all) {
        for (final c in all) {
          if (ask([a, b, c])) return [a, b, c];
        }
      }
    }
    return null;
  }

  /// A ranking's rotations: the three ballots of the ring, if the ballots
  /// are all the rotations of one ranking.
  static bool allRotations(List<List<int>> profile) {
    final base = profile.first;
    final n = base.length;
    final seen = <String>{};
    for (final ballot in profile) {
      var isRotation = false;
      for (var r = 0; r < n && !isRotation; r++) {
        final turned = [for (var i = 0; i < n; i++) base[(i + r) % n]];
        if (turned.join() == ballot.join()) isRotation = true;
      }
      if (!isRotation) return false;
      seen.add(ballot.join());
    }
    return seen.length == n;
  }
}
