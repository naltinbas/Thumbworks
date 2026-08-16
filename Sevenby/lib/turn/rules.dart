/// Fractions k over a prime p and their decimals: the digits come round
/// after so many places, the period, which is the number of steps 10
/// takes to come back to 1 on the p-hour clock, and never more than
/// p - 1.
class Rules {
  /// The primes on the dial: every prime from 3 to 47 but 5, whose
  /// tenths end.
  static const primes = [3, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47];

  /// Every setting: a prime and a numerator 1 to p - 1.
  static int get settings => primes.fold(0, (n, p) => n + p - 1);

  /// The long division of k by p: the digits of the repeating block and
  /// the remainders that gave them, the first remainder being k itself.
  /// The block is as long as it takes for a remainder to come again.
  /// The first voice.
  static (List<int>, List<int>) divide(int k, int p) {
    final digits = <int>[], remainders = <int>[];
    var r = k % p;
    while (!remainders.contains(r)) {
      remainders.add(r);
      digits.add(r * 10 ~/ p);
      r = r * 10 % p;
    }
    return (digits, remainders);
  }

  /// The period by long division: how many digits before the remainders
  /// come round.
  static int periodByDivision(int k, int p) => divide(k, p).$1.length;

  static int powMod(int b, int e, int p) {
    var out = 1 % p, x = b % p, n = e;
    while (n > 0) {
      if (n.isOdd) out = out * x % p;
      x = x * x % p;
      n >>= 1;
    }
    return out;
  }

  /// The period by the clock: the fewest steps e with 10 to the e one
  /// more than a multiple of p, the least divisor of p - 1 that does it.
  /// The second voice, no division at all.
  static int periodByClock(int p) {
    for (var e = 1; e <= p - 1; e++) {
      if ((p - 1) % e == 0 && powMod(10, e, p) == 1) return e;
    }
    throw StateError('10 never comes round on $p');
  }

  /// The block of digits as a number: 142857 for a seventh.
  static BigInt blockValue(List<int> digits) => digits.fold(BigInt.zero, (a, d) => a * BigInt.from(10) + BigInt.from(d));

  /// Nines as long as the block: 999,999 for a seventh.
  static BigInt nines(int n) => BigInt.from(10).pow(n) - BigInt.one;

  /// Whether the digits of k over p read the same as those of 1 over p
  /// started somewhere else round the ring.
  static bool isRotation(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var s = 0; s < a.length; s++) {
      var same = true;
      for (var i = 0; i < a.length && same; i++) {
        if (a[(i + s) % a.length] != b[i]) same = false;
      }
      if (same) return true;
    }
    return false;
  }

  /// A prime whose reciprocal takes the whole turn, p - 1 digits.
  static bool isFullTurn(int p) => periodByClock(p) == p - 1;

  static String tellDigits(List<int> digits) => digits.join();

  static String commas(BigInt n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
