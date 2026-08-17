import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Whole Four',
      kind: 'whole',
      lean: 0,
      ways: 26,
      aim: (4, 3, 0, 0),
      note: 'The two sums agree wherever the peg stands, but the four '
          'distances themselves are usually roots. All four come out whole '
          'on 26 of the 11,025 standings, and the plainest is the peg on a '
          'post, where three of the distances are the sides and the fourth '
          'is the diagonal of a hall like the three by four.',
    ),
    Level(
      name: 'The Even Corners',
      kind: 'same',
      lean: 0,
      ways: 16,
      aim: (4, 4, 2, 2),
      note: 'All four posts the same distance off means the peg is at the '
          'middle of the hall, which only lands on a point of the field when '
          'both sides are even. That is 16 standings of the 11,025, one for '
          'each even hall.',
    ),
    Level(
      name: 'The Fifty',
      kind: 'fifty',
      lean: 0,
      ways: 90,
      aim: (3, 3, -3, 1),
      note: 'Fifty is the sum of the two squares to opposite posts, and by '
          'the theorem the other pair comes to fifty as well. 90 standings '
          'of the 11,025 do it, and most of them have the peg well outside '
          'the hall, since the sum grows with the distance and the halls are '
          'small.',
    ),
    Level(
      name: 'The Peg Within',
      kind: 'inside',
      lean: 0,
      ways: 2,
      aim: (6, 8, 3, 4),
      note: 'Whole distances with the peg inside the hall happen twice in '
          'the 11,025: the six by eight hall and its turn about, with the '
          'peg three paces along and four up. Every distance is five there, '
          'and the two sums are fifty each.',
    ),
    Level(
      name: 'The Leaning Hall',
      kind: 'agree',
      lean: 2,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. Multiply '
          'the brackets out and the peg drops away from the difference '
          'entirely: the two sums part company by twice the lean times the '
          'width, whatever the hall and wherever the peg stands. With a lean '
          'of two that is four times the width, which is never nought for '
          'any hall the dials allow. The theorem wants square corners and '
          'this hall has none.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
