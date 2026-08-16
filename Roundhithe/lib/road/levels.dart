import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Ring',
      kind: 'ring',
      ways: 60,
      note: 'Six roads is the fewest a round trip needs, one in and one out '
          'at every village, and 60 of the 5,005 plans of six roads are '
          'such a ring, one for each way round the six villages; of all '
          '32,768 road-plans, 10,078 have a round trip.',
    ),
    Level(
      name: 'The Two Trios',
      kind: 'trios',
      ways: 10,
      note: 'Seventy plans give every village two roads, and 60 are rings; '
          'the other ten are two trios, three villages ringed among '
          'themselves and the other three too, and no road between the '
          'trios, so no trip gets round. Two roads each is not enough for '
          'Dirac: 10,210 plans have some village at two roads and no '
          'fewer, and 1,990 of them have no round trip.',
    ),
    Level(
      name: 'The Nine Roads',
      kind: 'nine',
      ways: 70,
      note: 'Seventy plans give every village three roads exactly, nine '
          'roads in all, and every one of them has a round trip, as Dirac '
          'said: three is half of the five others rounded up, and 1,858 '
          'plans in all reach three at every village, with a round trip on '
          'every one.',
    ),
    Level(
      name: 'The Eleven',
      kind: 'eleven',
      ways: 30,
      note: 'Eleven roads is the most a plan can have and still lack a round '
          'trip: 30 plans do it, and every one is five villages joined '
          'every way, ten roads, and the sixth hung on one of them by a '
          'single road, a dead end no trip gets past. Every plan of twelve '
          'roads or more has a round trip, all 576 of them.',
    ),
    Level(
      name: 'The Three Each',
      kind: 'dirac',
      ways: 0,
      note: 'Hopeless, and the tile says so. Dirac proved in 1952 that a map '
          'in which every village has half the others as neighbours at '
          'least has a round trip through all of them: take a longest '
          'road-walk that repeats no village, and every neighbour of '
          'either end lies on it, since a neighbour off it would make the '
          'walk longer; with three neighbours each, the two ends have '
          'neighbours enough on the walk that some road from one end lands '
          'just after a road from the other, and the walk turns into a '
          'ring, which takes in any village left over. The sweep of all '
          '32,768 road-plans finds 1,858 with three roads or more at every '
          'village, and a round trip on every one; and 1,978 meeting Ore\'s '
          'wider rule of 1960, six roads between any two villages not '
          'joined, with a round trip on every one of those too.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
