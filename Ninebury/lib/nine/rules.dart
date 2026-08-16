/// Numbers of three digits and their roots: the digits added again and
/// again until one is left, and the remainder by nine, which is the
/// same thing.
class Rules {
  /// The dials show three digits, so the numbers run 0 to [most].
  static const most = 999;

  /// The digits of [n], hundreds first, always three.
  static List<int> digits(int n) => [n ~/ 100 % 10, n ~/ 10 % 10, n % 10];

  static int digitSum(int n) => digits(n).fold(0, (a, d) => a + d);

  /// The sums down to a single digit: 738 gives [738, 18, 9]; 9 gives
  /// [9]. The first voice.
  static List<int> chain(int n) {
    final out = [n];
    var at = n;
    while (at > 9) {
      var sum = 0;
      for (var m = at; m > 0; m ~/= 10) {
        sum += m % 10;
      }
      at = sum;
      out.add(at);
    }
    return out;
  }

  /// The root by adding digits: the chain's last.
  static int rootByDigits(int n) => chain(n).last;

  /// The root by nines: nought for nought, else nine when nine divides
  /// the number, else the remainder. The second voice, no digits read.
  static int rootByNines(int n) => n == 0 ? 0 : 1 + (n - 1) % 9;

  /// How many nines the number holds and what is over.
  static (int, int) cast(int n) => (n ~/ 9, n % 9);

  static bool isSquare(int n) {
    for (var k = 0; k * k <= n; k++) {
      if (k * k == n) return true;
    }
    return false;
  }

  static bool isCube(int n) {
    for (var k = 0; k * k * k <= n; k++) {
      if (k * k * k == n) return true;
    }
    return false;
  }

  static bool allDifferent(int n) => digits(n).toSet().length == 3;

  /// The number the slip is measured against: 47 times 18.
  static const factors = (47, 18);
  static int get product => factors.$1 * factors.$2;

  /// The chain told: '7 + 3 + 8 = 18, 1 + 8 = 9'.
  static String told(int n) {
    final c = chain(n);
    if (c.length == 1) return '$n stands alone';
    final parts = <String>[];
    for (var i = 0; i + 1 < c.length; i++) {
      final ds = c[i].toString().split('').join(' + ');
      parts.add('$ds = ${c[i + 1]}');
    }
    return parts.join(', ');
  }
}
