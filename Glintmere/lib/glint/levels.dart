import 'level.dart';

/// The five asks, first to last. They all stand on one board: the lamp
/// and the eye never move, and only the asking tightens. Every count is
/// the sweep's, and the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Thirteen',
      paces: 13,
      ways: 9,
      fewest: 1,
      note: '9 of the 13 pegs bring the path within 13 paces, which is most '
          'of the mirror. The two ends are too far out: from the far left '
          'the light goes a long way sideways for very little crossing, and '
          'the same at the right.',
    ),
    Level(
      name: 'The Twelve',
      paces: 12,
      ways: 7,
      fewest: 2,
      note: '7 pegs bring it within 12. Each pace taken off the asking '
          'takes a peg off each end, because the path grows as the bounce '
          'moves away from the middle and it grows the same either way.',
    ),
    Level(
      name: 'The Eleven',
      paces: 11,
      ways: 5,
      fewest: 3,
      note: '5 pegs bring it within 11. The count has run 9, then 7, then '
          '5, and the pegs left are always the ones nearest the bounce the '
          'light would take of its own accord.',
    ),
    Level(
      name: 'The Even Angles',
      paces: 10,
      ways: 1,
      fewest: 5,
      note: '1 peg brings it within 10, and 10 paces is the least any path '
          'here can come to. That peg is the one where the angle the light '
          'comes in at matches the angle it leaves at, and its two legs are '
          '5 paces and 5 paces, each a three by four corner. Hero of '
          'Alexandria set this down in his Catoptrics: light takes the '
          'shortest way, and the shortest way is the one with matching '
          'angles.',
    ),
    Level(
      name: 'The Nine',
      paces: 9,
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Fold the '
          'board along the mirror and the eye comes to rest 8 down and 6 '
          'across from the lamp, a straight run of 10. Every bounce turns '
          'into a bent path from the lamp to that folded eye, and no bent '
          'path is shorter than the straight one. So 10 is the floor, and 9 '
          'is under it. Not on this board and not on any other: the sweep '
          'walks 54,925 settings of lamp, eye and bounce and no path '
          'anywhere beats its own straight run.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
