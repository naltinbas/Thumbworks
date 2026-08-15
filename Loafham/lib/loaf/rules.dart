import 'fraction.dart';

/// The law of the loaf.
///
/// A share of loaf, four fifths say, to be cut as unit fractions,
/// a half and a quarter and a twentieth, no two alike: the way the
/// Rhind papyrus writes every share. Fibonacci showed in 1202 that
/// the greedy cut, always the biggest unit fraction that fits,
/// finishes every share, since what is left has a smaller top each
/// time; Sylvester found the same in 1880. The board offers cuts
/// from a half down to a twenty-fourth, and the sweep tries every
/// set of them: two of three comes one way in two cuts, four of
/// five two ways in three and never in two, since a half leaves
/// three tenths and no half leaves seven twelfths at the most.
class Rules {
  Rules(this.share, {this.largest = 24});

  /// The share to be cut.
  final Fraction share;

  /// The finest cut on the board: a twenty-fourth.
  final int largest;

  /// The cuts on the board, halves to twenty-fourths.
  List<int> get cuts => [for (var d = 2; d <= largest; d++) d];

  /// The sum of a set of cuts.
  static Fraction sumOf(Iterable<int> cuts) =>
      cuts.fold(Fraction.zero, (sum, d) => sum + Fraction.unit(d));

  /// Whether a set of cuts makes the share exactly.
  bool makes(Iterable<int> cuts) => sumOf(cuts) == share;

  /// Every set of exactly [count] cuts from the board that makes
  /// the share, in order.
  List<List<int>> waysWith(int count) {
    final found = <List<int>>[];
    final picked = <int>[];
    void choose(int from, Fraction sum) {
      if (sum > share) return;
      if (picked.length == count) {
        if (sum == share) found.add(List.of(picked));
        return;
      }
      for (var d = from; d <= largest; d++) {
        picked.add(d);
        choose(d + 1, sum + Fraction.unit(d));
        picked.removeLast();
      }
    }

    choose(2, Fraction.zero);
    return found;
  }

  /// How many sets of at most [count] cuts make the share.
  int waysBySweep(int count) {
    var ways = 0;
    for (var k = 1; k <= count; k++) {
      ways += waysWith(k).length;
    }
    return ways;
  }

  /// The fewest cuts from the board that make the share, or null
  /// when none up to [most] do.
  int? fewest({int most = 5}) {
    for (var k = 1; k <= most; k++) {
      if (waysWith(k).isNotEmpty) return k;
    }
    return null;
  }

  /// The first set of at most [count] cuts the sweep finds, fewest
  /// first, or null.
  List<int>? landing(int count) {
    for (var k = 1; k <= count; k++) {
      final found = waysWith(k);
      if (found.isNotEmpty) return found.first;
    }
    return null;
  }

  /// The greedy cuts: the biggest unit fraction that fits, again
  /// and again, until nothing is left. Fibonacci's method, and it
  /// always ends, since the top of what is left falls each time.
  static List<int> greedy(Fraction share) {
    final cuts = <int>[];
    var left = share;
    while (!left.isZero) {
      // The least d with 1/d at most left: ceiling of den/num.
      final d = (left.den + left.num - 1) ~/ left.num;
      cuts.add(d);
      left = left - Fraction.unit(d);
    }
    return cuts;
  }
}
