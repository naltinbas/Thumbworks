/// The law of the rows.
///
/// A heap of pebbles laid out in rows of equal length: the row
/// lengths that come out even, with no pebble over, are the
/// divisors of the heap's count, and how many there are is the
/// oldest question about a number. Write the count as primes
/// raised to powers and the answer is the product of the powers
/// each raised by one, since a divisor takes each prime to any
/// power up to the top. Twelve even rows come from sixty first,
/// then seventy-two, eighty-four, ninety and ninety-six; seven
/// even rows come from sixty-four alone; and thirteen even rows
/// need a single prime to the twelfth, four thousand and
/// ninety-six at the least, so no heap of the hundred has them.
class Rules {
  Rules({this.most = 100});

  /// The biggest heap on the board.
  final int most;

  /// The divisors of a count, by trial: every row length that
  /// comes out even.
  static List<int> divisors(int n) =>
      [for (var d = 1; d <= n; d++) if (n % d == 0) d];

  /// How many even rows, by trial.
  static int rowsByTrial(int n) => divisors(n).length;

  /// The count written as primes to powers, smallest prime first.
  static List<(int, int)> factors(int n) {
    final out = <(int, int)>[];
    var left = n;
    for (var p = 2; p * p <= left; p++) {
      var e = 0;
      while (left % p == 0) {
        left ~/= p;
        e++;
      }
      if (e > 0) out.add((p, e));
    }
    if (left > 1) out.add((left, 1));
    return out;
  }

  /// How many even rows, by the powers: each power raised by one,
  /// multiplied together, no trial anywhere.
  static int rowsByPowers(int n) =>
      factors(n).fold(1, (product, f) => product * (f.$2 + 1));

  /// Every heap on the board with exactly [asked] even rows.
  List<int> heapsWith(int asked) =>
      [for (var n = 1; n <= most; n++) if (rowsByTrial(n) == asked) n];

  /// The smallest heap anywhere with exactly [asked] even rows,
  /// searched up to [limit]; null past it.
  static int? smallestWith(int asked, {int limit = 5000}) {
    for (var n = 1; n <= limit; n++) {
      if (rowsByPowers(n) == asked) return n;
    }
    return null;
  }

  /// The heaps on the board that set a new record for even rows:
  /// the highly composite ones.
  List<int> records() {
    final out = <int>[];
    var best = 0;
    for (var n = 1; n <= most; n++) {
      final rows = rowsByTrial(n);
      if (rows > best) {
        best = rows;
        out.add(n);
      }
    }
    return out;
  }
}
