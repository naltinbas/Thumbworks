import 'field.dart';

/// The four numbers of the smallest field there is after the two everybody
/// knows: 0, 1, and the two roots of x² = x + 1.
///
/// Adding is exclusive-or of the two bits. Multiplying is not needed here;
/// what is needed is one fact, and it is the whole reason this file exists:
///
///     a² = a + 1,  so  a^k + a^(k+1) = a^k(1 + a) = a^k · a² = a^(k+2)
///
/// Three squares in a row carry a^k, a^(k+1), a^(k+2). A jump takes the pegs
/// on the first two and puts one on the third — and by that identity the sum
/// over every peg on the board does not change. Not for that jump: for every
/// jump, in every direction, from any position whatever.
///
/// Which makes it an invariant, and an invariant is a proof that costs
/// nothing to check.
class Four {
  const Four._(this.bits);

  /// 0, 1, a, a+1 as two bits.
  final int bits;

  static const zero = Four._(0);
  static const one = Four._(1);
  static const a = Four._(2);

  /// a to the power of [n], which is all this needs of multiplying. The three
  /// non-zero values repeat every third power: 1, a, a+1, 1, a, a+1...
  static Four power(int n) => const [one, a, Four._(3)][n % 3];

  Four operator +(Four other) => Four._(bits ^ other.bits);

  @override
  bool operator ==(Object other) => other is Four && other.bits == bits;

  @override
  int get hashCode => bits;

  @override
  String toString() => const ['0', '1', 'a', 'a+1'][bits];
}

/// What the two invariants say about a bag of pegs.
///
/// Label the hollow in row r and column c with a^(r+c) for one sum and with
/// a^(r-c) for the other. Both sums are the same before and after every jump,
/// so a position can only ever become a position with the same pair.
///
/// Which is why this can rule out a finish without any searching at all: one
/// peg left in hollow h is a position whose pair is that hollow's own pair,
/// so if the pair on the board is not that hollow's pair, no sequence of
/// jumps however long ends there.
class RuleOfThree {
  RuleOfThree(this.field) {
    _down = [
      for (var hollow = 0; hollow < field.hollows; hollow++)
        Four.power(field.rowOf(hollow) + field.columnOf(hollow)),
    ];
    _up = [
      for (var hollow = 0; hollow < field.hollows; hollow++)
        // Kept away from a negative power by adding a multiple of three that
        // is bigger than any board here.
        Four.power(field.rowOf(hollow) - field.columnOf(hollow) + 999),
    ];
  }

  final Field field;
  late final List<Four> _down;
  late final List<Four> _up;

  /// The pair of sums for a bag of pegs.
  (Four, Four) of(int pegs) {
    var down = Four.zero;
    var up = Four.zero;
    for (var hollow = 0; hollow < field.hollows; hollow++) {
      if (pegs & (1 << hollow) == 0) continue;
      down = down + _down[hollow];
      up = up + _up[hollow];
    }
    return (down, up);
  }

  /// The pair a single peg in a hollow would have.
  (Four, Four) forOne(int hollow) => (_down[hollow], _up[hollow]);

  /// Whether a bag of pegs could possibly come down to one peg in a hollow.
  ///
  /// It is a "could": the sums agreeing does not make it so. But the sums
  /// disagreeing makes it impossible, and that is what this is for.
  bool couldFinishAt(int pegs, int hollow) => of(pegs) == forOne(hollow);

  /// Every hollow a bag of pegs could possibly come down to.
  List<int> couldFinish(int pegs) => [
        for (var hollow = 0; hollow < field.hollows; hollow++)
          if (couldFinishAt(pegs, hollow)) hollow,
      ];
}
