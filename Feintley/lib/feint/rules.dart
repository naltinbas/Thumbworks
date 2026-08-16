/// Fermat's test: a number n is asked to raise a base a to the power
/// n - 1 and land on one, working modulo n. Every prime passes for
/// every base it does not divide, as Fermat wrote in 1640; a composite
/// that passes is a liar for that base, 341 the first for base two,
/// and a composite that passes for every base it shares no factor
/// with is a Carmichael number, 561 the first.
class Rules {
  static const least = 2, most = 1200;
  static const leastBase = 2, mostBase = 12;

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// The power by squaring, working modulo n all the way: the first
  /// voice.
  static int powMod(int base, int power, int n) {
    var result = 1 % n;
    var b = base % n;
    var e = power;
    while (e > 0) {
      if (e.isOdd) result = result * b % n;
      b = b * b % n;
      e >>= 1;
    }
    return result;
  }

  /// The power taken whole, big as it is, and only then brought down
  /// modulo n: the second voice.
  static int powWhole(int base, int power, int n) => (BigInt.from(base).pow(power) % BigInt.from(n)).toInt();

  /// Whether n passes the test on base a: the base raised to n - 1
  /// lands on one.
  static bool passes(int a, int n) => n >= 2 && powMod(a, n - 1, n) == 1;

  static bool isPrime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  /// The primes to [most], by the sieve: the second voice for
  /// primeness.
  static List<bool> get sieve {
    final flags = List<bool>.filled(most + 1, true);
    flags[0] = false;
    flags[1] = false;
    for (var p = 2; p * p <= most; p++) {
      if (!flags[p]) continue;
      for (var k = p * p; k <= most; k += p) {
        flags[k] = false;
      }
    }
    return flags;
  }

  /// A liar: composite and passing on the base.
  static bool liar(int a, int n) => !isPrime(n) && passes(a, n);

  /// Whether n passes for every base from 2 to 12 that it shares no
  /// factor with, and shares a factor with none of... no: whether it
  /// passes for every base it shares no factor with: a Carmichael
  /// number when composite, on the bases the dials hold.
  static bool passesAllCoprimeBases(int n) {
    for (var b = leastBase; b <= mostBase; b++) {
      if (gcd(b, n) == 1 && !passes(b, n)) return false;
    }
    return true;
  }

  static bool carmichael(int n) => !isPrime(n) && n > 1 && passesAllCoprimeBases(n) && [for (var b = leastBase; b <= mostBase; b++) if (gcd(b, n) == 1) b].isNotEmpty;

  /// The smallest factor of a composite, or null for a prime.
  static int? factor(int n) {
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return d;
    }
    return null;
  }

  /// The repeated squares of the base, a, a squared, a to the fourth and
  /// on, modulo n, with a mark on each the power n - 1 takes: the
  /// running product of the marked ones is the landing.
  static List<(int, int, bool)> squares(int a, int n) {
    final out = <(int, int, bool)>[];
    var b = a % n;
    var e = n - 1;
    var k = 0;
    while (e > 0) {
      out.add((k, b, e.isOdd));
      b = b * b % n;
      e >>= 1;
      k++;
    }
    return out;
  }

  static String tell(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
