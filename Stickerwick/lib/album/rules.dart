import 'frac.dart';

export 'frac.dart';

/// The arithmetic of the album: a set of n stickers, one to a packet at
/// random and each as likely as the rest, and how many packets it takes
/// to fill the album. Two voices for the average: the stages, the k-th
/// new sticker taking n/(n - k + 1) packets on average, added; and the
/// tail, the chance the album is still short after m packets summed over
/// every m, which by counting the ways closes to an alternating sum of
/// binomials, n/j times C(n, j) with the signs turning. And the chance
/// the album is full after m packets, by counting the ways too.
class Rules {
  /// The dials: stickers in the set, one to this; packets, one to this.
  static const mostStickers = 12;
  static const mostPackets = 60;

  static const settings = mostStickers * mostPackets;

  static BigInt _n(int x) => BigInt.from(x);

  static BigInt choose(int n, int k) {
    var c = BigInt.one;
    for (var i = 0; i < k; i++) {
      c = c * _n(n - i) ~/ _n(i + 1);
    }
    return c;
  }

  /// The average packets to fill a set of [n], by the stages: n/n + n/(n-1)
  /// + ... + n/1, which is n times the n-th harmonic number.
  static Frac averageByStages(int n) {
    var sum = Frac.zero;
    for (var left = n; left >= 1; left--) {
      sum = sum + Frac.of(n, left);
    }
    return sum;
  }

  /// The average by the tail: the sum over m of the chance the album is
  /// short after m packets, which counting closes to sum over j = 1..n of
  /// (-1)^(j+1) C(n, j) n/j.
  static Frac averageByTail(int n) {
    var sum = Frac.zero;
    for (var j = 1; j <= n; j++) {
      final term = Frac(choose(n, j) * _n(n), _n(j));
      sum = j.isOdd ? sum + term : sum - term;
    }
    return sum;
  }

  /// The chance the album is full after [m] packets, by counting the
  /// ways: sum over j of (-1)^j C(n, j) ((n - j)/n)^m.
  static Frac fullAfter(int n, int m) {
    var sum = Frac.zero;
    for (var j = 0; j <= n; j++) {
      final term = Frac(choose(n, j) * _n(n - j).pow(m), _n(n).pow(m));
      sum = j.isEven ? sum + term : sum - term;
    }
    return sum;
  }

  /// The chance by walking the packets one at a time: the chance of
  /// holding exactly k stickers after m packets, m steps of a table,
  /// the second voice for the chance.
  static Frac fullAfterByWalk(int n, int m) {
    var held = List<Frac>.filled(n + 1, Frac.zero);
    held[0] = Frac.one;
    for (var step = 0; step < m; step++) {
      final next = List<Frac>.filled(n + 1, Frac.zero);
      for (var k = 0; k <= n; k++) {
        if (held[k] == Frac.zero) continue;
        // A packet repeats one of the k held with chance k/n, else adds one.
        next[k] = next[k] + held[k] * Frac.of(k, n);
        if (k < n) next[k + 1] = next[k + 1] + held[k] * Frac.of(n - k, n);
      }
      held = next;
    }
    return held[n];
  }

  /// The fewest packets that make the album more likely full than not.
  static int median(int n) {
    for (var m = 1; m <= 10000; m++) {
      if (fullAfter(n, m).compareTo(Frac.of(1, 2)) >= 0) return m;
    }
    return -1;
  }

  /// A fraction as a decimal to two places, cut not rounded.
  static String decimal(Frac f) {
    final hundredths = f.n * BigInt.from(100) ~/ f.d;
    final whole = hundredths ~/ BigInt.from(100), rest = hundredths % BigInt.from(100);
    return '$whole.${rest.toString().padLeft(2, '0')}';
  }
}
