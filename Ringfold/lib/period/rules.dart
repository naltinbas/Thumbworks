/// The Fibonacci numbers on a clock of m hours: 0, 1, 1, 2, 3, 5, 8 and
/// on, each the two before added and cut down by m; they come round to
/// 0, 1 again after so many steps, the period, which is even for every
/// clock past two.
class Rules {
  /// The clocks run from [least] to [most] hours.
  static const least = 2, most = 40;

  static int get settings => most - least + 1;

  /// The Fibonacci numbers on the clock until 0, 1 comes round again:
  /// the whole cycle, one period long. The first voice, walked pair by
  /// pair.
  static List<int> cycle(int m) {
    final out = <int>[0 % m, 1 % m];
    var a = 0 % m, b = 1 % m;
    while (true) {
      final c = (a + b) % m;
      a = b;
      b = c;
      if (a == 0 % m && b == 1 % m) break;
      out.add(b);
    }
    // The last two written are the 0 and 1 that come round; drop them so
    // the cycle holds one period exactly.
    return out.sublist(0, out.length - 1);
  }

  /// The period by walking: the cycle's length.
  static int periodByWalk(int m) => cycle(m).length;

  /// The two-by-two Fibonacci matrix, 1 1 / 1 0, raised to [n] on the
  /// clock by squaring: (a, b, c, d) for the entries a b / c d.
  static (int, int, int, int) matrixPower(int n, int m) {
    var result = (1 % m, 0, 0, 1 % m);
    var base = (1 % m, 1 % m, 1 % m, 0);
    var k = n;
    (int, int, int, int) times((int, int, int, int) x, (int, int, int, int) y) => (
          (x.$1 * y.$1 + x.$2 * y.$3) % m,
          (x.$1 * y.$2 + x.$2 * y.$4) % m,
          (x.$3 * y.$1 + x.$4 * y.$3) % m,
          (x.$3 * y.$2 + x.$4 * y.$4) % m,
        );
    while (k > 0) {
      if (k.isOdd) result = times(result, base);
      base = times(base, base);
      k >>= 1;
    }
    return result;
  }

  /// A bound the period must divide, from the clock's prime factors: for
  /// a prime p ending 1 or 9 the period divides p - 1, for one ending 3
  /// or 7 it divides 2 (p + 1), for 5 it is 20 and for 2 it is 3; each
  /// power of p multiplies by p, and the clock's bound is the least
  /// common multiple over its prime powers.
  static int bound(int m) {
    var out = 1;
    var rest = m;
    for (var p = 2; p * p <= rest || p <= rest; p++) {
      if (rest % p != 0) continue;
      var k = 0;
      while (rest % p == 0) {
        rest ~/= p;
        k++;
      }
      var b = p == 2 ? 3 : p == 5 ? 20 : (p % 5 == 1 || p % 5 == 4) ? p - 1 : 2 * (p + 1);
      for (var i = 1; i < k; i++) {
        b *= p;
      }
      out = _lcm(out, b);
    }
    return out;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
  static int _lcm(int a, int b) => a ~/ _gcd(a, b) * b;

  /// The period by the matrix: the least divisor of the bound that
  /// brings the Fibonacci matrix back to the identity on the clock. The
  /// second voice, no walk.
  static int periodByMatrix(int m) {
    final b = bound(m);
    for (var d = 1; d <= b; d++) {
      if (b % d != 0) continue;
      if (matrixPower(d, m) == (1 % m, 0, 0, 1 % m)) return d;
    }
    throw StateError('the matrix never comes round on $m within $b');
  }

  /// Cassini's identity on the clock: F(n-1) F(n+1) - F(n) squared is
  /// plus or minus one, the sign turning each step.
  static bool cassiniHolds(int m) {
    final c = cycle(m);
    final n = c.length;
    for (var i = 1; i < 2 * n; i++) {
      final before = c[(i - 1) % n], at = c[i % n], after = c[(i + 1) % n];
      final want = i.isEven ? 1 : m - 1;
      if (((before * after - at * at) % m + m) % m != want % m) return false;
    }
    return true;
  }
}
