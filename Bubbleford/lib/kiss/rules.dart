/// Three bubbles kissing, each touching the other two, and the two
/// bubbles that kiss all three, one in the gap between and one round
/// the outside. Call a bubble's bend one over its radius: Descartes
/// found in 1643 that the four bends satisfy (a + b + c + d)^2 =
/// 2(a^2 + b^2 + c^2 + d^2), so the fourth bend is a + b + c give or
/// take twice the root of ab + bc + ca, the outer bubble's bend
/// counted negative, nought when it flattens to a line. Soddy set it
/// to verse in 1936.
class Rules {
  static const least = 1, most = 20;

  /// Every setting of the three dials, in order.
  static List<List<int>> get triples => [
        for (var a = least; a <= most; a++)
          for (var b = least; b <= most; b++)
            for (var c = least; c <= most; c++) [a, b, c],
      ];

  static int get count => (most - least + 1) * (most - least + 1) * (most - least + 1);

  static bool valid(List<int> k) => k.length == 3 && k.every((x) => x >= least && x <= most);

  static int sum(List<int> k) => k[0] + k[1] + k[2];

  /// The pairwise products added: ab + bc + ca.
  static int pairs(List<int> k) => k[0] * k[1] + k[1] * k[2] + k[2] * k[0];

  static int squares(List<int> k) => k[0] * k[0] + k[1] * k[1] + k[2] * k[2];

  /// The whole square root of [n], or null when n is no square.
  static int? root(int n) {
    if (n < 0) return null;
    var r = 0;
    while ((r + 1) * (r + 1) <= n) {
      r++;
    }
    return r * r == n ? r : null;
  }

  /// Whether both fourth bends are whole: the pairwise sum a square.
  static bool whole(List<int> k) => root(pairs(k)) != null;

  /// The two fourth bends when whole, the inner first, or null.
  static (int, int)? fourths(List<int> k) {
    final r = root(pairs(k));
    return r == null ? null : (sum(k) + 2 * r, sum(k) - 2 * r);
  }

  /// The outer bend's sign: below nought and the outer bubble wraps
  /// round the three, nought and it is a straight line, above and it
  /// sits in the gap on the far side. Exact by squares: s against 2
  /// root q is s^2 against 4q.
  static int outerSign(List<int> k) {
    final s = sum(k), q = pairs(k);
    return (s * s - 4 * q).sign;
  }

  /// Whether Descartes' relation holds for the four bends [a], [b], [c]
  /// and [d], exactly: the second voice, applied to whole fourths found
  /// by trying every whole bend in a range.
  static bool descartes(int a, int b, int c, int d) {
    final s = a + b + c + d;
    return s * s == 2 * (a * a + b * b + c * c + d * d);
  }

  /// The whole fourth bends found by trial: every d from -most * 3 to
  /// most * 9 tried against Descartes' relation.
  static List<int> fourthsByTrial(List<int> k) => [
        for (var d = -3 * most; d <= 9 * most; d++)
          if (descartes(k[0], k[1], k[2], d)) d,
      ];

  /// The bends told: '2, 2 and 3'.
  static String tell(List<int> k) => '${k[0]}, ${k[1]} and ${k[2]}';

  /// A fourth bend told exactly: '15', '-1', '3 + 2 root 3', '3 - 2 root 3'.
  static String tellFourth(List<int> k, {required bool inner}) {
    final s = sum(k), q = pairs(k);
    final r = root(q);
    if (r != null) return '${inner ? s + 2 * r : s - 2 * r}';
    // Pull squares out of the root: 2 root q = 2 m root n with n square-free.
    var m = 1, n = q;
    for (var f = 2; f * f <= n; f++) {
      while (n % (f * f) == 0) {
        n ~/= f * f;
        m *= f;
      }
    }
    final twice = 2 * m;
    return '$s ${inner ? '+' : '-'} $twice root $n';
  }
}
