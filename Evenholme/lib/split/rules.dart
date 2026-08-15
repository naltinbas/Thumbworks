/// The arithmetic of the split: an even number written as two primes,
/// Goldbach's way. Two voices for the primes, the sieve and trial
/// division, and the sweep of every even number to two thousand for its
/// splits.
class Rules {
  /// How far the sieve and the sweep run.
  static const top = 2000;

  static List<bool>? _sieve;

  /// Eratosthenes' sieve to [top]: true at the primes.
  static List<bool> get sieve {
    if (_sieve != null) return _sieve!;
    final s = List.filled(top + 1, true);
    s[0] = false;
    s[1] = false;
    for (var p = 2; p * p <= top; p++) {
      if (!s[p]) continue;
      for (var m = p * p; m <= top; m += p) {
        s[m] = false;
      }
    }
    return _sieve = s;
  }

  /// Whether [n] is prime, by the sieve.
  static bool isPrime(int n) => n >= 0 && n <= top && sieve[n];

  /// Whether [n] is prime, by trial division, the second voice.
  static bool isPrimeByTrial(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  /// The splits of [n]: every pair of primes (p, q) with p at most q and
  /// p + q = n, smallest p first.
  static List<(int, int)> splits(int n) => [
        for (var p = 2; p <= n - p; p++)
          if (isPrime(p) && isPrime(n - p)) (p, n - p),
      ];

  /// The primes to [n], smallest first.
  static List<int> primesTo(int n) => [
        for (var p = 2; p <= n; p++)
          if (isPrime(p)) p,
      ];

  /// A split told: '3 + 17'.
  static String told((int, int) s) => '${s.$1} + ${s.$2}';
}
