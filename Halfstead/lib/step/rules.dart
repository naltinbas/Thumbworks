import 'frac.dart';

/// A runner in a corridor, the wall one whole length away, taking a
/// share of what is left at every step: how far the steps reach, and
/// why never the wall.
class Rules {
  /// The shares of what is left a step may cover.
  static final shares = <Frac>[Frac.of(1, 2), Frac.of(1, 3), Frac.of(2, 3), Frac.of(3, 4), Frac.of(9, 10)];

  /// The steps run from one to [most].
  static const most = 40;

  static int get settings => shares.length * most;

  /// What is left after [n] steps of [share]: the rest of each step, to
  /// the n. The second voice, no steps added.
  static Frac left(Frac share, int n) => (Frac.one - share).pow(n);

  /// How far the runner has come after [n] steps, by the second voice.
  static Frac coveredByForm(Frac share, int n) => Frac.one - left(share, n);

  /// The steps themselves: the first a share of the whole, each next a
  /// share of what the last left.
  static List<Frac> steps(Frac share, int n) {
    final out = <Frac>[];
    var remaining = Frac.one;
    for (var k = 0; k < n; k++) {
      final step = remaining * share;
      out.add(step);
      remaining = remaining - step;
    }
    return out;
  }

  /// How far the runner has come, by adding the steps. The first voice.
  static Frac coveredBySum(Frac share, int n) => steps(share, n).fold(Frac.zero, (a, s) => a + s);

  /// The fewest steps of [share] that leave no more than [within].
  static int fewestWithin(Frac share, Frac within) {
    for (var n = 1; n <= most; n++) {
      if (left(share, n).compareTo(within) <= 0) return n;
    }
    return most + 1;
  }

  /// A share told: 'half', 'a third', 'two thirds', 'three quarters',
  /// 'nine tenths'.
  static String tellShare(Frac share) {
    if (share == Frac.of(1, 2)) return 'half';
    if (share == Frac.of(1, 3)) return 'a third';
    if (share == Frac.of(2, 3)) return 'two thirds';
    if (share == Frac.of(3, 4)) return 'three quarters';
    if (share == Frac.of(9, 10)) return 'nine tenths';
    return '$share';
  }

  static String commas(BigInt n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  /// A fraction told with commas in big numbers: '1/1,048,576'.
  static String tell(Frac f) => f.isWhole ? commas(f.n) : '${commas(f.n)}/${commas(f.d)}';
}
