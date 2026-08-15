/// The arithmetic of the tithe: a number and the sum of its proper
/// divisors, every divisor but the number itself. Two voices: the count,
/// each candidate divisor tried in turn; and the formula, the sum of all
/// divisors built from the prime factors, each prime's powers summed and
/// the sums multiplied, less the number.
class Rules {
  /// The dial runs from one to this.
  static const most = 500;

  /// How many settings the dial has.
  static const settings = most;

  /// The proper divisors of [n], smallest first, by trial.
  static List<int> divisors(int n) => [
        for (var d = 1; d < n; d++)
          if (n % d == 0) d,
      ];

  /// The sum of the proper divisors, by the count.
  static int tithe(int n) => divisors(n).fold(0, (a, b) => a + b);

  /// The prime factors of [n] with their powers, smallest first.
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

  /// The sum of the proper divisors, by the formula: for each prime power
  /// p^k the divisors' sum is 1 + p + ... + p^k, the products of those
  /// over the primes give the sum of all divisors, and the number itself
  /// comes off.
  static int titheByFormula(int n) {
    var all = 1;
    for (final (p, k) in factors(n)) {
      var powers = 0, pk = 1;
      for (var i = 0; i <= k; i++) {
        powers += pk;
        pk *= p;
      }
      all *= powers;
    }
    return all - n;
  }

  static bool isPerfect(int n) => tithe(n) == n;

  static bool isPrime(int n) => n >= 2 && factors(n).length == 1 && factors(n).first.$2 == 1;

  static bool isPowerOfTwo(int n) => n >= 1 && (n & (n - 1)) == 0;

  /// Euclid's perfect numbers to [most]: 2^(p-1) (2^p - 1) with 2^p - 1
  /// prime.
  static List<int> get euclidPerfect => [
        for (var p = 2; (1 << (p - 1)) * ((1 << p) - 1) <= most; p++)
          if (isPrime((1 << p) - 1)) (1 << (p - 1)) * ((1 << p) - 1),
      ];

  /// Sweeps every setting of the dial: how many meet [ask], how many
  /// there are, and the first that meets it.
  static (int, int, int?) sweep(bool Function(int n) ask) {
    var met = 0;
    int? first;
    for (var n = 1; n <= most; n++) {
      if (ask(n)) {
        met++;
        first ??= n;
      }
    }
    return (met, most, first);
  }

  /// A list told: '1, 2, 4, 7 and 14'.
  static String told(List<int> xs) {
    if (xs.isEmpty) return 'nothing';
    if (xs.length == 1) return '${xs.first}';
    return '${xs.sublist(0, xs.length - 1).join(', ')} and ${xs.last}';
  }
}
