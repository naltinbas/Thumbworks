/// Prime clocks and the squares on them: which hours some base squares
/// to, by squaring every base and by Euler's test.
class Rules {
  /// The clocks the dial runs over: the primes from three to
  /// twenty-three.
  static const clocks = [3, 5, 7, 11, 13, 17, 19, 23];

  /// Every setting: a clock and a base on it, 1 to clock - 1.
  static int get settings => clocks.fold(0, (n, p) => n + p - 1);

  /// The hours some base squares to, by squaring every base. The first
  /// voice.
  static Set<int> squaresByBases(int p) => {for (var a = 1; a < p; a++) a * a % p};

  static int powMod(int b, int e, int p) {
    var out = 1 % p, x = b % p, n = e;
    while (n > 0) {
      if (n.isOdd) out = out * x % p;
      x = x * x % p;
      n >>= 1;
    }
    return out;
  }

  /// Euler's test: an hour h other than 0 is a square on the odd prime
  /// clock p exactly when h to the (p - 1) / 2 comes to 1; otherwise it
  /// comes to p - 1. The second voice, no square taken.
  static bool isSquareByEuler(int h, int p) => powMod(h % p, (p - 1) ~/ 2, p) == 1;

  /// The hours some base squares to, by Euler's test.
  static Set<int> squaresByEuler(int p) => {for (var h = 1; h < p; h++) if (isSquareByEuler(h, p)) h};

  /// The bases whose square is [h] on the clock.
  static List<int> rootsOf(int h, int p) => [for (var a = 1; a < p; a++) if (a * a % p == h % p) a];

  static bool isPrime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  /// The hours told: '1, 2 and 4'.
  static String told(Iterable<int> hours) {
    final l = hours.toList()..sort();
    return l.length == 1 ? '${l.first}' : '${l.sublist(0, l.length - 1).join(', ')} and ${l.last}';
  }

  /// A number in words, one to twenty-four.
  static String name(int n) => const [
        'nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
        'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen',
        'nineteen', 'twenty', 'twenty-one', 'twenty-two', 'twenty-three', 'twenty-four'
      ][n];
}
