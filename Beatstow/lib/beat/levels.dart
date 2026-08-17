import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Rest Beat',
      rack: [0, 1, 2, 5, 7],
      ways: 20,
      fewest: 10,
      note: '20 of the 120 layings juggle, which is the most any rack of '
          'three balls on five beats manages, and only two racks reach it. A '
          'throw of nothing is a rest: the hand stays empty and the beat '
          'passes. It still counts towards the total, which is why a rest '
          'costs the rack nothing and buys it room.',
    ),
    Level(
      name: 'The Five Throws',
      rack: [1, 2, 3, 4, 5],
      ways: 15,
      fewest: 10,
      note: '15 of the 120 layings juggle. Every height from one to five, '
          'each used once, adding to 15, which is three balls on five beats. '
          'A throw of five goes right round the ring and comes down on the '
          'beat it left, so it can only sit where nothing else lands.',
    ),
    Level(
      name: 'The Double Three',
      rack: [1, 2, 3, 3, 6],
      ways: 10,
      fewest: 10,
      note: '10 of the 60 layings juggle. Two throws of the same height can '
          'never sit on the same beat, so the pair of threes has to be kept '
          'apart, and the six behaves like a one because six round a ring of '
          'five is one over.',
    ),
    Level(
      name: 'The Seven',
      rack: [1, 1, 3, 3, 7],
      ways: 5,
      fewest: 10,
      note: '5 of the 30 layings juggle, and they are one laying and its '
          'four turnings. Turning a rack round the ring sends a pattern to a '
          'pattern, which is why every count of ways here divides by five: '
          '20, 15, 10 and 5 are four rhythms, three, two and one, each '
          'counted five times over.',
    ),
    Level(
      name: 'The Raised Throw',
      rack: [3, 3, 3, 3, 4],
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Add the '
          'five throws: 3 and 3 and 3 and 3 and 4 come to 16, and 16 into 5 '
          'will not go. Rearranging moves the same five tiles about, so the '
          'total never changes, and the total has to be the balls times the '
          'beats for any pattern at all. Four tiles will go down, ten '
          'different ways, and the fifth is refused from every free beat '
          'every time. All 74 racks of five single-figure throws adding to '
          '16 are the same story.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
