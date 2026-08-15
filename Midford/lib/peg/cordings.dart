import 'cording.dart';

/// The five cordings that ship.
///
/// Every number here is checked before the bake: the sweep of every
/// ordered four on the board, both readings of every figure held to
/// one another, and tool/check_cords.dart refuses the lot if
/// anything disagrees.
class Cordings {
  static const all = [
    Cording(
      name: 'The Cross Cords',
      asked: Asked.rectangle,
      given: [],
      ways: 27952,
      fours: 303600,
      note: 'The midpoint figure is a rectangle exactly when the two '
          'diagonals of your pegs cross square, 27,952 ordered fours of '
          'the 303,600 on the board.',
    ),
    Cording(
      name: 'The Even Cords',
      asked: Asked.rhombus,
      given: [],
      ways: 18384,
      fours: 303600,
      note: 'The midpoint figure is a rhombus exactly when the two '
          'diagonals of your pegs are of a length, 18,384 fours.',
    ),
    Cording(
      name: 'The Square Cords',
      asked: Asked.square,
      given: [],
      ways: 11248,
      fours: 303600,
      note: 'Square when the diagonals cross square and are of a length '
          'both, 11,248 fours; the smallest is a square of pegs itself.',
    ),
    Cording(
      name: 'The Fourth Peg',
      asked: Asked.fourthPeg,
      given: [(0, 0), (4, 0), (4, 3)],
      ways: 1,
      fours: 22,
      note: 'Three pegs given, the fourth must set the second diagonal '
          'square across the first, and one peg of the twenty-two left '
          'does it.',
    ),
    Cording(
      name: 'The Skew',
      asked: Asked.skew,
      given: [],
      ways: 0,
      fours: 303600,
      note: 'The first side of the midpoint figure is half the first '
          'diagonal, and so is the side across from it, both read off '
          'the midpoints and off the diagonal for every one of the '
          '303,600 fours; when the diagonals lie along one line the '
          'figure flattens, and it is a parallelogram still.',
    ),
  ];

  static int get count => all.length;

  static Cording at(int number) => all[number];
}
