import 'rules.dart';

/// The house: on an even-by-even quilt where it sews second, it sews
/// the patch across the middle from yours; where one side is odd
/// and it sews first, it takes the middle patch and then mirrors;
/// anywhere else it plays the tree, a winning patch if there is one
/// and the first that fits if not.
class House {
  /// The house's patch on a quilt that is not sewn out, with the word
  /// for how it chose: mirror, middle, winning or any.
  static (Patch, String) advise(Quilt quilt, int sewn, {required bool houseFirst, Patch? yourLast}) {
    final middle = quilt.middle;
    final evenByEven = quilt.rows.isEven && quilt.cols.isEven;
    if (!houseFirst && evenByEven && yourLast != null) {
      final back = quilt.mirror(yourLast);
      if (quilt.fits(sewn, back)) return (back, 'mirror');
    }
    if (houseFirst && middle != null) {
      if (sewn == 0) return (middle, 'middle');
      if (yourLast != null) {
        final back = quilt.mirror(yourLast);
        if (quilt.fits(sewn, back)) return (back, 'mirror');
      }
    }
    final winning = quilt.winningMoves(sewn);
    if (winning.isNotEmpty) return (winning.first, 'winning');
    return (quilt.moves(sewn).first, 'any');
  }
}
