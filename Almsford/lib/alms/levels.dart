import 'level.dart';

/// The five asks, first to last. Each count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'Three Small Heaps',
      shape: [7, 1, 1, 1, 0],
      ways: 20,
      fewest: 2,
      note: '20 of the 1,001 arrangements stand in this shape, and two '
          'shares reach it: the big bin has enough over every other to give '
          'twice. Note that the empty bin can never be filled from a bin '
          'holding one, since a bin has to be two ahead before it can give.',
    ),
    Level(
      name: 'The Even Halves',
      shape: [5, 5, 0, 0, 0],
      ways: 10,
      fewest: 4,
      note: '10 of the 1,001 arrangements stand in this shape. Four shares '
          'from the opening, all of them out of the same bin and into the '
          'same one, which is as direct as a share-out gets. The other three '
          'bins are never given anything, though nothing stops them: a bin '
          'holding two or more can always give to an empty one.',
    ),
    Level(
      name: 'The Staircase',
      shape: [4, 3, 2, 1, 0],
      ways: 120,
      fewest: 5,
      note: '120 of the 1,001 arrangements stand in this shape, more than any '
          'other shape here, since all five heights differ and so every '
          'ordering of the bins counts. Five shares reach it.',
    ),
    Level(
      name: 'The Level Field',
      shape: [2, 2, 2, 2, 2],
      ways: 1,
      fewest: 7,
      note: 'One arrangement of the 1,001, and the furthest of all: seven '
          'shares from the opening, which is as far as any shape lies. Every '
          'shape covers this one, so a share-out can always reach it, and '
          'once there nothing can move at all, since no bin is two ahead of '
          'another.',
    ),
    Level(
      name: 'The One Heap',
      shape: [10, 0, 0, 0, 0],
      ways: 5,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. A share '
          'takes a measure out of the fuller bin, so the fullest bin never '
          'rises; nor do the two fullest together, nor the three, and so on '
          'down. The opening has nine in its fullest bin and this ask wants '
          'ten, so no run of shares can get there. Of the 30 shapes the grain '
          'can stand in, 29 can be reached from the opening and this is the '
          'one that cannot.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
