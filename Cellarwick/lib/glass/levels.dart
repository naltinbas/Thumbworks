import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The One Unit',
      kind: 'unit',
      ways: 9,
      aim: (2, 2, 2),
      note: 'Two units of water and a spoon of two: the spoon of wine makes '
          'the water glass half and half, and the spoon back carries one '
          'unit of water home, and one of wine stays behind. Nine settings '
          'of the 500, whatever the wine glass holds from two up: the water '
          'that comes back is spoon times water over water plus spoon, and '
          'that is one only at two and two.',
    ),
    Level(
      name: 'The Tenth',
      kind: 'tenth',
      ways: 5,
      aim: (5, 1, 1),
      note: 'Five settings of the 500 leave the wine glass one tenth water: '
          'five of wine, one of water and a spoon of one; eight, one and a '
          'spoon of four; eight, four and one; nine, nine and one; ten, two '
          'and two. Ten of each with a spoon of one leave it ten elevenths '
          'wine, not nine tenths.',
    ),
    Level(
      name: 'The Whole Spoon',
      kind: 'whole',
      ways: 24,
      aim: (2, 2, 2),
      note: 'The water that comes back is spoon times water over water plus '
          'spoon, and it is whole in 24 settings of the 500: two of water '
          'and a spoon of two give one unit, four and four give two, six of '
          'water and a spoon of three give two, each with any wine glass '
          'the spoon can be filled from.',
    ),
    Level(
      name: 'The Half and Half',
      kind: 'half',
      ways: 40,
      aim: (1, 1, 1),
      note: 'The water glass ends half wine exactly when the spoon holds as '
          'much as the water glass did: 40 settings of the 500, spoons of '
          'one to five with as much water and any wine glass the spoon '
          'fills from. Then the spoon back is half and half too.',
    ),
    Level(
      name: 'The Unequal',
      kind: 'unequal',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. The wine glass ends holding as '
          'much as it began with, so the water in it fills exactly the room '
          'the missing wine left, and that wine is all in the water glass: '
          'the two are always equal, stirred well or not at all, and none of '
          'the 500 settings breaks it in any of the three stirs.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
