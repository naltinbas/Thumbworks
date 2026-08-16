/// The clocks and the walks: a base's powers stepping round the hours
/// of a clock, and whether they come home to 1.
class Rules {
  /// The clocks the dials run over, [least] to [most] hours.
  static const least = 3, most = 24;

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// The walk of [base] on the [clock]: 1, base, base squared and on,
  /// each hour taken once, stopping short of the first hour seen
  /// before. The first voice: multiplication, step by step.
  static List<int> walk(int base, int clock) {
    final seen = <int>[];
    var at = 1 % clock;
    while (!seen.contains(at)) {
      seen.add(at);
      at = at * base % clock;
    }
    return seen;
  }

  /// The hour the walk falls back to after its last step: 1 when it
  /// comes home, some other hour when it never does.
  static int fallsTo(int base, int clock) {
    final w = walk(base, clock);
    return w.last * base % clock;
  }

  /// Whether the walk comes home to 1.
  static bool comesHome(int base, int clock) => fallsTo(base, clock) == 1 % clock;

  /// The steps the walk takes to come home, or null when it never does:
  /// the order of the base, by walking.
  static int? orderByWalk(int base, int clock) =>
      comesHome(base, clock) ? walk(base, clock).length : null;

  /// The hours sharing no factor with the clock: the ones any base that
  /// comes home can touch, and all a full base does touch.
  static List<int> units(int clock) => [for (var h = 1; h < clock; h++) if (gcd(h, clock) == 1) h];

  /// Euler's phi: how many hours share no factor with the clock.
  static int phi(int n) => units(n).length;

  /// The prime factors of [n] with their powers, least first.
  static List<(int, int)> factors(int n) {
    final out = <(int, int)>[];
    var m = n;
    for (var p = 2; p * p <= m; p++) {
      var k = 0;
      while (m % p == 0) {
        m ~/= p;
        k++;
      }
      if (k > 0) out.add((p, k));
    }
    if (m > 1) out.add((m, 1));
    return out;
  }

  static int lcm(int a, int b) => a ~/ gcd(a, b) * b;

  /// Carmichael's lambda: the longest any base's walk on the clock can
  /// take to come home, from the prime factors alone.
  static int lambda(int n) {
    var out = 1;
    for (final (p, k) in factors(n)) {
      final part = p == 2 ? (k <= 2 ? 1 << (k - 1) : 1 << (k - 2)) : pow(p, k - 1) * (p - 1);
      out = lcm(out, part);
    }
    return out;
  }

  static int pow(int b, int e) {
    var out = 1;
    for (var i = 0; i < e; i++) {
      out *= b;
    }
    return out;
  }

  /// [b] to the [e] on the [clock], by squaring: no walk taken.
  static int powMod(int b, int e, int clock) {
    var out = 1 % clock, x = b % clock, n = e;
    while (n > 0) {
      if (n.isOdd) out = out * x % clock;
      x = x * x % clock;
      n >>= 1;
    }
    return out;
  }

  /// The order of [base] on the [clock] by the second voice: null when
  /// they share a factor, else the least divisor of Carmichael's lambda
  /// that brings the base to 1 by squaring.
  static int? orderByLambda(int base, int clock) {
    if (gcd(base, clock) != 1) return null;
    final l = lambda(clock);
    for (var d = 1; d <= l; d++) {
      if (l % d == 0 && powMod(base, d, clock) == 1 % clock) return d;
    }
    throw StateError('no divisor of lambda brings $base home on $clock');
  }

  /// Whether the base is a primitive root of the clock: its walk touches
  /// every hour sharing no factor with the clock.
  static bool isFull(int base, int clock) => orderByWalk(base, clock) == phi(clock);

  /// Whether the clock has a full base at all, by Gauss's rule: 2, 4, a
  /// power of an odd prime, or twice one.
  static bool hasFullByGauss(int clock) {
    if (clock <= 4) return true;
    final f = factors(clock);
    if (f.length == 1) return f.first.$1 != 2;
    return f.length == 2 && f.first == (2, 1);
  }

  /// Whether the clock has a full base at all, by the sweep of its bases.
  static bool hasFullByWalk(int clock) => [for (var b = 1; b < clock; b++) b].any((b) => isFull(b, clock));

  /// The settings the two dials reach: every base of every clock.
  static int get settings {
    var n = 0;
    for (var c = least; c <= most; c++) {
      n += c - 1;
    }
    return n;
  }

  /// The walk told: '1, 2, 4 and 8'.
  static String told(List<int> hours) => hours.length == 1
      ? '${hours.first}'
      : '${hours.sublist(0, hours.length - 1).join(', ')} and ${hours.last}';

  /// A number in words, three to twenty-four.
  static String name(int n) => const [
        'nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
        'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen',
        'nineteen', 'twenty', 'twenty-one', 'twenty-two', 'twenty-three', 'twenty-four'
      ][n];
}
