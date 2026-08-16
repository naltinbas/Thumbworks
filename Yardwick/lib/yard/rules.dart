/// Two hedges, the first of the mth Fibonacci length and the second of
/// the nth, and the longest yardstick that measures both without
/// remainder: it is the Fibonacci number of the common measure of m
/// and n, since two Fibonacci numbers share exactly the factors their
/// counts share. Lucas set it down in 1876; and one Fibonacci number
/// divides another exactly when its count divides the other's, save
/// that the first two, both one, divide everything.
class Rules {
  static const most = 30;

  /// The Fibonacci numbers by count: fib(1) = fib(2) = 1.
  static BigInt fib(int n) {
    var a = BigInt.zero, b = BigInt.one;
    for (var i = 0; i < n; i++) {
      final c = a + b;
      a = b;
      b = c;
    }
    return a;
  }

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// The longest yardstick by Euclid on the hedges themselves, the first
  /// voice: the greatest common divisor of the two Fibonacci numbers.
  static BigInt measureByHedges(int m, int n) => fib(m).gcd(fib(n));

  /// The yardstick by the counts, the second voice: the Fibonacci number
  /// of the common measure of m and n.
  static BigInt measureByCounts(int m, int n) => fib(gcd(m, n));

  /// The steps Euclid takes on the two counts, told: (30, 12) -> (12, 6) -> (6, 0).
  static List<(int, int)> euclidOnCounts(int m, int n) {
    final steps = <(int, int)>[];
    var a = m, b = n;
    while (b != 0) {
      steps.add((a, b));
      final r = a % b;
      a = b;
      b = r;
    }
    steps.add((a, 0));
    return steps;
  }

  /// Whether the mth Fibonacci number divides the nth.
  static bool divides(int m, int n) => fib(n) % fib(m) == BigInt.zero;

  /// Whether the counts say so: m divides n, or m is 1 or 2.
  static bool dividesByCounts(int m, int n) => m <= 2 || n % m == 0;

  static bool isPrime(BigInt n) {
    if (n < BigInt.two) return false;
    var d = BigInt.two;
    while (d * d <= n) {
      if (n % d == BigInt.zero) return false;
      d += BigInt.one;
    }
    return true;
  }

  static bool isPrimeInt(int n) => isPrime(BigInt.from(n));

  /// A number with commas: 832,040.
  static String tell(BigInt n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
