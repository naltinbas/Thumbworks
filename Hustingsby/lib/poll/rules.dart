/// The arithmetic of the count: Ash's ballots and Birch's, drawn from
/// the box one at a time in some order, and the running lead. Three
/// voices: the sweep, every order of the ballots read through; Bertrand's
/// formula, the majority over the poll of the orders keep Ash ahead
/// throughout; and the reflection, the orders that keep him ahead being
/// the orders that start with an Ash ballot less those that touch level
/// after, counted by a mirror.
class Rules {
  /// Every order of [ash] Ash ballots and [birch] Birch ballots, each a
  /// list of true for Ash and false for Birch, in the order the sweep
  /// finds them, Ash first.
  static List<List<bool>> orders(int ash, int birch) {
    final out = <List<bool>>[];
    final order = <bool>[];
    void go(int a, int b) {
      if (a == 0 && b == 0) {
        out.add(List.of(order));
        return;
      }
      if (a > 0) {
        order.add(true);
        go(a - 1, b);
        order.removeLast();
      }
      if (b > 0) {
        order.add(false);
        go(a, b - 1);
        order.removeLast();
      }
    }

    go(ash, birch);
    return out;
  }

  /// The lead after each ballot: Ash's count less Birch's, ballot by
  /// ballot.
  static List<int> leads(List<bool> order) {
    var lead = 0;
    return [for (final a in order) lead += a ? 1 : -1];
  }

  /// Whether Ash is ahead after every ballot.
  static bool aheadThroughout(List<bool> order) => order.isNotEmpty && leads(order).every((l) => l > 0);

  /// Whether Ash is never behind, level allowed.
  static bool neverBehind(List<bool> order) => leads(order).every((l) => l >= 0);

  /// How many times the count stands level after a ballot.
  static int levels(List<bool> order) => leads(order).where((l) => l == 0).length;

  /// How many times the lead changes hands: a strict lead for one side
  /// followed, after any levels, by a strict lead for the other.
  static int changesOfHands(List<bool> order) {
    var last = 0, changes = 0;
    for (final l in leads(order)) {
      if (l == 0) continue;
      final side = l.sign;
      if (last != 0 && side != last) changes++;
      last = side;
    }
    return changes;
  }

  static int choose(int n, int k) {
    if (k < 0 || k > n) return 0;
    var c = 1;
    for (var i = 0; i < k; i++) {
      c = c * (n - i) ~/ (i + 1);
    }
    return c;
  }

  /// Bertrand's count of the orders that keep Ash ahead throughout: the
  /// majority over the poll of them all, (a - b)/(a + b) of C(a+b, a).
  static int aheadByBertrand(int ash, int birch) => ash + birch == 0 ? 0 : (ash - birch) * choose(ash + birch, ash) ~/ (ash + birch);

  /// The same by the reflection: orders that start with Ash, C(a+b-1,
  /// a-1), less those that start with Ash and touch level after, which
  /// mirror one to one onto the orders that start with Birch, C(a+b-1, a).
  static int aheadByReflection(int ash, int birch) => ash == 0 ? 0 : choose(ash + birch - 1, ash - 1) - choose(ash + birch - 1, ash);

  /// The orders that never put Ash behind, level allowed, by the formula
  /// (a - b + 1)/(a + 1) of C(a+b, a): Catalan's numbers when a = b.
  static int neverBehindByFormula(int ash, int birch) => ash < birch ? 0 : (ash - birch + 1) * choose(ash + birch, ash) ~/ (ash + 1);

  /// The count of an order, told: 'A B A A B'.
  static String told(List<bool> order) => order.map((a) => a ? 'A' : 'B').join(' ');
}
