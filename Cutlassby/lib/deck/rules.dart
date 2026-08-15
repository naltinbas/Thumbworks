/// The law of the deck: the captain divides the gold among the crew,
/// captain first, and every pirate votes; the plan passes with the
/// ayes at least half, the captain's own among them; if it fails the
/// captain goes over the side and the next pirate is captain. Every
/// pirate votes for what pays him: aye only if his share beats what he
/// would get with the captain gone, which is the best plan of the crew
/// one smaller, reckoned the same way.
class Rules {
  const Rules(this.gold);

  /// Coins to divide.
  final int gold;

  /// Every division of the gold among [n] pirates, captain first.
  List<List<int>> divisions(int n) {
    final out = <List<int>>[];
    void go(List<int> so, int left, int slots) {
      if (slots == 1) {
        out.add([...so, left]);
        return;
      }
      for (var k = left; k >= 0; k--) {
        go([...so, k], left - k, slots - 1);
      }
    }

    go([], gold, n);
    return out;
  }

  /// What each pirate but the captain would get with the captain gone:
  /// the best plan of the crew one smaller, each pirate one rank up.
  /// The captain's own entry is nought, he being over the side.
  List<int> expects(int n) {
    if (n <= 1) return [0];
    final smaller = best(n - 1);
    return [0, ...smaller];
  }

  /// The votes on [plan]: the captain aye, and every other pirate aye
  /// exactly when his share beats what he expects with the captain gone.
  List<bool> votes(List<int> plan) {
    final n = plan.length;
    final want = expects(n);
    return [for (var i = 0; i < n; i++) i == 0 || plan[i] > want[i]];
  }

  int ayes(List<int> plan) => votes(plan).where((v) => v).length;

  /// Ayes needed: half the crew, rounded up.
  int needed(int n) => (n + 1) ~/ 2;

  bool passes(List<int> plan) => ayes(plan) >= needed(plan.length);

  /// The best plan for [n] pirates: of the plans that pass, the one that
  /// keeps the captain the most, and it is one alone here, checked.
  List<int> best(int n) {
    if (_bests.containsKey(n)) return _bests[n]!;
    if (n == 1) return _bests[n] = [gold];
    List<int>? top;
    var ties = 0;
    for (final plan in divisions(n)) {
      if (!passes(plan)) continue;
      if (top == null || plan[0] > top[0]) {
        top = plan;
        ties = 1;
      } else if (plan[0] == top[0]) {
        ties++;
      }
    }
    if (top == null || ties != 1) {
      throw StateError('$n pirates: ${top == null ? 'no plan passes' : '$ties best plans'}');
    }
    return _bests[n] = top;
  }

  /// The most the captain of [n] can keep, by the sweep of every plan.
  int mostKept(int n) => best(n)[0];

  /// The plans keeping the captain at least [keep] coins: (passing, all).
  (int, int) sweep(int n, int keep) {
    var passing = 0, all = 0;
    for (final plan in divisions(n)) {
      if (plan[0] < keep) continue;
      all++;
      if (passes(plan)) passing++;
    }
    return (passing, all);
  }

  static final _bests = <int, List<int>>{};
}
