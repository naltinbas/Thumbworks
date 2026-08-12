/// The law of the tiles.
///
/// A hoard is paid by two square tiles, one a-wide and one
/// b-wide, when a squared plus b squared lands it exactly.
/// Fermat's 1640 law says a prime one past a four-times always
/// pays, one way only; and no hoard three past a four-times
/// ever pays, since a square ends at nought or one past a
/// four-times, and two of them reach two past at the most. The
/// sweep dials every pair of tiles and holds both laws whole.
class Rules {
  /// The widest tile the dials reach.
  static const widest = 9;

  /// Every writing of a hoard: tile pairs, narrow tile first,
  /// both at least one.
  static List<(int, int)> writings(int hoard) => [
        for (var a = 1; a <= widest; a++)
          for (var b = a; b <= widest; b++)
            if (a * a + b * b == hoard) (a, b),
      ];

  /// The remainder voice: what a hoard leaves past the largest
  /// four-times under it.
  static int pastFours(int hoard) => hoard % 4;

  /// Whether the remainder alone bars the hoard: squares leave
  /// nought or one, so two squares leave two at the most.
  static bool barredByFours(int hoard) => pastFours(hoard) == 3;

  /// Brahmagupta's identity, executed: the writings of a
  /// product, one per sign, from a writing of each factor. A
  /// sign can land the empty tile, which the dials cannot
  /// reach: composing five with itself pays twenty-five as
  /// three and four, or as nought and five.
  static List<(int, int)> composed(
      (int, int) one, (int, int) two) {
    final (a, b) = one;
    final (c, d) = two;
    final minus = _sorted((a * c - b * d).abs(), a * d + b * c);
    final plus = _sorted(a * c + b * d, (a * d - b * c).abs());
    return minus == plus ? [minus] : [minus, plus];
  }

  static (int, int) _sorted(int a, int b) =>
      a <= b ? (a, b) : (b, a);

  /// The primes one past a four-times, up to a hundred: the
  /// hoards Fermat promises exactly one writing.
  static List<int> get fermatPrimes => [
        for (var hoard = 2; hoard < 100; hoard++)
          if (_prime(hoard) && hoard % 4 == 1) hoard,
      ];

  static bool _prime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  /// Both laws held over every hoard the dials reach: the
  /// remainder bar, and Fermat's one writing per prime. True
  /// when nothing breaks.
  static bool lawsHold() {
    for (var hoard = 1; hoard <= 200; hoard++) {
      if (barredByFours(hoard) && writings(hoard).isNotEmpty) {
        return false;
      }
    }
    for (final prime in fermatPrimes) {
      if (writings(prime).length != 1) return false;
    }
    return true;
  }
}
