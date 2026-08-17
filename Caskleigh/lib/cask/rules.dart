import 'frac.dart';

/// A cellar of casks. The first holds a whole barrel, the second a
/// half, the third a third and so on down. Pour a run of them together,
/// from the ath to the bth, and the question is what the total comes
/// to.
///
/// It is never a whole barrel. Among any run of whole numbers there is
/// exactly one with more twos in it than any other, and when the
/// fractions are put over a common bottom that one term comes out odd
/// on top while every other comes out even, so the total has an even
/// bottom and cannot be whole. Jozsef Kurschak wrote the argument down
/// in 1918, and Erdos gave another in 1932 using Bertrand's postulate.
class Rules {
  /// The casks the cellar holds.
  static const most = 60;

  /// The run a go opens on.
  static const openFirst = 3, openLast = 4;

  static bool validRun(int first, int last) =>
      first >= 1 && last <= most && first < last;

  /// What the run from the [first] cask to the [last] comes to,
  /// exactly.
  static Frac total(int first, int last) {
    var out = Frac.zero;
    for (var k = first; k <= last; k++) {
      out = out + Frac.of(1, k);
    }
    return out;
  }

  /// The same worked out over a common bottom, in whole numbers alone:
  /// the second voice. It multiplies out to the same fraction and never
  /// divides until the end.
  static Frac totalByCommon(int first, int last) {
    var bottom = BigInt.one;
    for (var k = first; k <= last; k++) {
      bottom = _lcm(bottom, BigInt.from(k));
    }
    var top = BigInt.zero;
    for (var k = first; k <= last; k++) {
      top += bottom ~/ BigInt.from(k);
    }
    return Frac(top, bottom);
  }

  static BigInt _lcm(BigInt a, BigInt b) => a ~/ a.gcd(b) * b;

  /// The smallest number every cask of the run divides into.
  static BigInt commonBottom(int first, int last) {
    var bottom = BigInt.one;
    for (var k = first; k <= last; k++) {
      bottom = _lcm(bottom, BigInt.from(k));
    }
    return bottom;
  }

  /// How many times the casks of the run go into that bottom, added
  /// up. This is the total before anything is cancelled, which is the
  /// form the argument is made in: odd on top, even underneath.
  static BigInt commonTop(int first, int last) {
    final bottom = commonBottom(first, last);
    var top = BigInt.zero;
    for (var k = first; k <= last; k++) {
      top += bottom ~/ BigInt.from(k);
    }
    return top;
  }

  /// How many twos are in [n].
  static int twos(int n) {
    var count = 0, left = n;
    while (left.isEven) {
      left ~/= 2;
      count++;
    }
    return count;
  }

  /// The most twos any cask of the run has in it.
  static int mostTwos(int first, int last) {
    var top = 0;
    for (var k = first; k <= last; k++) {
      final has = twos(k);
      if (has > top) top = has;
    }
    return top;
  }

  /// The casks of the run with that many twos in them: always one, and
  /// that is the whole argument.
  static List<int> deepest(int first, int last) {
    final top = mostTwos(first, last);
    return [
      for (var k = first; k <= last; k++)
        if (twos(k) == top) k,
    ];
  }

  /// Whether the total comes to a whole number of barrels.
  static bool isWhole(int first, int last) => total(first, last).isWhole;

  /// Every run the cellar allows.
  static Iterable<(int, int)> runs() sync* {
    for (var first = 1; first <= most; first++) {
      for (var last = first + 1; last <= most; last++) {
        yield (first, last);
      }
    }
  }

  static int get howManyRuns => most * (most - 1) ~/ 2;

  /// The taps the dials take to reach a run from the opening.
  static int taps(int first, int last) =>
      (first - openFirst).abs() + (last - openLast).abs();

  static String tellRun(int first, int last) =>
      '${_article(first)} ${ordinal(first)} to ${_article(last)} '
      '${ordinal(last)}';

  /// An eighth, an eleventh, an eighteenth: the rest take a.
  static String _article(int k) {
    final told = ordinal(k);
    return told.startsWith('8') ||
            told.startsWith('11') ||
            told.startsWith('18')
        ? 'an'
        : 'a';
  }

  static String ordinal(int k) => '$k${_ending(k)}';

  static String _ending(int k) {
    if (k % 100 >= 11 && k % 100 <= 13) return 'th';
    switch (k % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// What the total comes to, told short. A long run has a bottom of
  /// twenty digits and more, which no chip on a phone will hold, so
  /// past fifteen characters it is given to four places instead. The
  /// exact fraction is what the game reasons with either way.
  static String tellTotal(Frac total) {
    final exact = total.toString();
    return exact.length <= 15
        ? exact
        : 'about ${total.toDouble.toStringAsFixed(4)}';
  }
}
