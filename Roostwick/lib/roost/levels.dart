import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two Thickets',
      board: 'ABACDEDF',
      ways: 9,
      fewest: 2,
      note: '9 of the 16 seatings settle this wood. It falls into two '
          'patches of three hollows apiece, each strung with two birds, '
          'and a patch with one fewer bird than hollows always settles: '
          'pick the hollow to leave empty and the rest follows. Three '
          'choices on one side, three on the other, so nine.',
    ),
    Level(
      name: 'The Three Pairs',
      board: 'ABABCDCDEFEF',
      ways: 8,
      fewest: 3,
      note: '8 of the 64 seatings settle this wood. Two birds strung '
          'between the same two hollows are not a crowd: they fill both '
          'hollows and there are two ways round, so three pairs settle '
          'two by two by two. Worth holding on to, because the ask that '
          'cannot be done is three birds on one tether rather than two.',
    ),
    Level(
      name: 'The Two Rings',
      board: 'ABBCACDEEFDF',
      ways: 4,
      fewest: 2,
      note: '4 of the 64 seatings settle this wood. Each patch is three '
          'hollows with three birds strung round them in a ring, so it '
          'fills every hollow it touches and can only turn one way or '
          'the other. Two ways each, four between them.',
    ),
    Level(
      name: 'The Hub',
      board: 'ABABACADAEAF',
      ways: 2,
      fewest: 5,
      note: '2 of the 64 seatings settle this wood, and the opening puts '
          'all six birds in hollow A at once, which is as far from '
          'settled as any wood of six hollows gets. The five birds hung '
          'off A have nowhere else to go, so they are forced; only the '
          'doubled tether between A and B is free, and it turns two '
          'ways. The two seatings are ABCDEF and BACDEF.',
    ),
    Level(
      name: 'The Shared Tether',
      board: 'ABABABCDDEEF',
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Six '
          'birds and six hollows, so nothing is short anywhere, and all '
          '64 seatings crowd hollow A or hollow B. Three birds share one '
          'tether and have two hollows between them. The other three sit '
          'across C, D, E and F, where they settle four ways with a '
          'hollow to spare, which is why two hollows stand empty while '
          'the jam refuses to clear.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
