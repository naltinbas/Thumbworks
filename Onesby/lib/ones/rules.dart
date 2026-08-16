/// Rows of ones: the numbers 2 to the p less 1, all ones in binary,
/// prime or not, and the two ways of telling.
class Rules {
  /// The dial runs over the exponents [least] to [most].
  static const least = 2, most = 31;

  static int get settings => most - least + 1;

  /// The row of p ones: 2 to the p less 1.
  static BigInt row(int p) => (BigInt.one << p) - BigInt.one;

  static bool isPrime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  /// The smallest factor of [n] past 1, or n itself when n is prime, by
  /// trial division. Sound for every row on the dial, whose square root
  /// is under 47,000.
  static BigInt smallestFactor(BigInt n) {
    if (n < BigInt.two) return n;
    for (var d = BigInt.two; d * d <= n; d += BigInt.one) {
      if (n % d == BigInt.zero) return d;
    }
    return n;
  }

  /// Whether the row of p ones is prime, by trial division. The first
  /// voice.
  static bool rowIsPrimeByDivision(int p) {
    final n = row(p);
    return n >= BigInt.two && smallestFactor(n) == n;
  }

  /// The Lucas-Lehmer chain for the row of p ones, p at least 3: 4, then
  /// each the last squared less two, cut down by the row, p - 2 steps;
  /// the row is prime exactly when the chain ends at 0.
  static List<BigInt> chain(int p) {
    final m = row(p);
    final out = [BigInt.from(4) % m];
    for (var i = 0; i < p - 2; i++) {
      out.add((out.last * out.last - BigInt.two) % m);
    }
    return out;
  }

  /// Whether the row of p ones is prime, by Lucas and Lehmer. The second
  /// voice: no division at all past the cutting down. Two ones are the
  /// number 3, prime, and the test does not speak of them.
  static bool rowIsPrimeByLucasLehmer(int p) => p == 2 || chain(p).last == BigInt.zero;

  /// The perfect number a prime row makes: 2 to the p - 1 times the row.
  static BigInt perfect(int p) => (BigInt.one << (p - 1)) * row(p);

  /// The sum of the divisors of [n] but n itself, by trial division:
  /// sound to a few hundred thousand million.
  static BigInt aliquot(BigInt n) {
    var sum = BigInt.one;
    for (var d = BigInt.two; d * d <= n; d += BigInt.one) {
      if (n % d == BigInt.zero) {
        sum += d;
        final e = n ~/ d;
        if (e != d) sum += e;
      }
    }
    return sum;
  }

  /// A row's smallest factor when the exponent is composite: for p = a b
  /// with a the smallest prime factor of p, the row of a ones divides
  /// the row of p ones.
  static int smallestExponentFactor(int p) {
    for (var d = 2; d * d <= p; d++) {
      if (p % d == 0) return d;
    }
    return p;
  }

  static String commas(BigInt n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
