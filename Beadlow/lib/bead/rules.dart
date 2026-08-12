/// The law of the stall.
///
/// A string is a ring of beads, each dyed one of a few dyes. Two
/// strings are the same necklace when some turn of the ring maps one
/// onto the other, and a necklace is told by its smallest turning.
///
/// How many necklaces a ring can make is known two ways that share
/// nothing. The shelf enumerates every string there is and folds
/// them by turning; the counting never strings a bead: each turn by
/// r beads fixes exactly dyes-to-the-gcd-of-r-and-n strings, and the
/// necklaces are the fixed counts summed over the turns and divided
/// by the turns. The suite proves the two against each other on
/// every ring that ships.
class Rules {
  /// The necklaces of [beads] beads in [dyes] dyes, by the counting
  /// alone: sum what each turn fixes, divide by the turns.
  static int byCounting(int beads, int dyes) {
    var fixedInAll = 0;
    for (var turn = 0; turn < beads; turn++) {
      fixedInAll += _power(dyes, _gcd(turn, beads));
    }
    return fixedInAll ~/ beads;
  }

  /// What each turn fixes, spelled out for the why.
  static List<int> fixedByTurn(int beads, int dyes) => [
        for (var turn = 0; turn < beads; turn++)
          _power(dyes, _gcd(turn, beads)),
      ];

  /// The necklace a string belongs to: its smallest turning.
  static List<int> necklaceOf(List<int> string) {
    var smallest = string;
    for (var turn = 1; turn < string.length; turn++) {
      final turned = [
        ...string.sublist(turn),
        ...string.sublist(0, turn),
      ];
      if (_compare(turned, smallest) < 0) smallest = turned;
    }
    return List.of(smallest);
  }

  /// Every necklace of the ring, told by its smallest turning, in
  /// order: the shelf enumerated string by string.
  static List<List<int>> shelf(int beads, int dyes) {
    final seen = <String>{};
    final necklaces = <List<int>>[];
    final string = List<int>.filled(beads, 0);

    void dye(int at) {
      if (at == beads) {
        final necklace = necklaceOf(string);
        if (seen.add(necklace.join(','))) {
          necklaces.add(necklace);
        }
        return;
      }
      for (var shade = 0; shade < dyes; shade++) {
        string[at] = shade;
        dye(at + 1);
      }
    }

    dye(0);
    return necklaces;
  }

  static int _power(int base, int raised) {
    var out = 1;
    for (var times = 0; times < raised; times++) {
      out *= base;
    }
    return out;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static int _compare(List<int> a, List<int> b) {
    for (var at = 0; at < a.length; at++) {
      if (a[at] != b[at]) return a[at] - b[at];
    }
    return 0;
  }
}
