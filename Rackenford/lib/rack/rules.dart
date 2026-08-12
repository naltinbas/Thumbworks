/// The law of the pantry.
///
/// Jars numbered one and up, racks to put them on, and one
/// rule: no rack may hold a jar and a jar that divides it.
/// Mirsky's 1971 law says the racks you need are exactly the
/// longest divisor chain in the jars, no more and no fewer:
/// the chain forces its length in racks, and racking every jar
/// by its chain height lands with exactly that many.
class Rules {
  Rules(this.top) : jars = [for (var n = 1; n <= top; n++) n];

  final int top;

  /// The jars, one to [top].
  final List<int> jars;

  /// Whether [a] divides [b] properly.
  static bool divides(int a, int b) => a != b && b % a == 0;

  /// Each jar's chain height: the longest divisor chain ending
  /// at it. The constructive voice, and the racking it builds.
  Map<int, int> get heights {
    final best = <int, int>{};
    for (final n in jars) {
      var tallest = 0;
      for (final m in jars) {
        if (m < n && divides(m, n) && best[m]! > tallest) {
          tallest = best[m]!;
        }
      }
      best[n] = tallest + 1;
    }
    return best;
  }

  /// The longest divisor chain in the jars.
  int get longestChain =>
      heights.values.reduce((a, b) => a > b ? a : b);

  /// The quarrels of a racking: same-rack pairs where one jar
  /// divides the other, unracked jars quarrelling with nobody.
  /// A racking is one rack index per jar, nought for unracked.
  List<(int, int)> quarrels(List<int> racking) => [
        for (var one = 0; one < jars.length; one++)
          for (var two = one + 1; two < jars.length; two++)
            if (racking[one] != 0 &&
                racking[one] == racking[two] &&
                divides(jars[one], jars[two]))
              (one, two),
      ];

  /// Whether a racking lands: every jar racked, no quarrels.
  bool lands(List<int> racking) =>
      racking.every((rack) => rack != 0) &&
      quarrels(racking).isEmpty;

  /// How many rackings on [racks] racks land, walked with the
  /// quarrels pruned as they appear.
  int waysTo(int racks) {
    final racking = List.filled(jars.length, 0);
    var ways = 0;
    void place(int at) {
      if (at == jars.length) {
        ways++;
        return;
      }
      for (var rack = 1; rack <= racks; rack++) {
        var clean = true;
        for (var earlier = 0; earlier < at && clean; earlier++) {
          if (racking[earlier] == rack &&
              divides(jars[earlier], jars[at])) {
            clean = false;
          }
        }
        if (!clean) continue;
        racking[at] = rack;
        place(at + 1);
        racking[at] = 0;
      }
    }

    place(0);
    return ways;
  }

  /// The racking by chain height, one rack per height. Drives
  /// the show-me, and proves Mirsky's count is enough.
  List<int> byHeights() {
    final tall = heights;
    return [for (final n in jars) tall[n]!];
  }
}
