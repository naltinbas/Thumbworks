import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Different',
      number: 8,
      kind: 'differentThree',
      ways: 2,
      note: 'Eight sunders into all-different parts six ways, 8, 7 + 1, 6 + 2, '
          '5 + 3, 5 + 2 + 1 and 4 + 3 + 1, and two of them have three parts '
          'or more: two of the 22 partitions of eight. Into all-odd parts '
          'eight sunders six ways too, as Euler said it must.',
    ),
    Level(
      name: 'The Odd Four',
      number: 8,
      kind: 'oddFour',
      ways: 2,
      note: 'Eight sunders into odd parts six ways, 7 + 1, 5 + 3, 5 + 1 + 1 + '
          '1, 3 + 3 + 1 + 1, 3 + five 1s and eight 1s, and two of them have '
          'four parts: two of the 22. Glaisher folds 5 + 1 + 1 + 1 to 5 + 2 + '
          '1 and 3 + 3 + 1 + 1 to 6 + 2, both all different.',
    ),
    Level(
      name: 'The Ten',
      number: 10,
      kind: 'different',
      ways: 10,
      note: 'Ten sunders into all-different parts ten ways of its 42, and into '
          'all-odd parts ten ways: the same count, as for every number to '
          'thirty, where 296 and 296 meet at the top of the sweep. Every '
          'all-odd partition folds to its own all-different one.',
    ),
    Level(
      name: 'The Square',
      number: 9,
      kind: 'threeByThree',
      ways: 1,
      note: 'Nine into three parts with the largest 3 is 3 + 3 + 3 alone, one '
          'of its 30, and it is its own turning: read down the columns of '
          'the dots it comes out the same. Every partition turned swaps its '
          'count of parts for its largest part, so nine sunders into k parts '
          'as many ways as into parts no bigger than k, for every k.',
    ),
    Level(
      name: 'The Odd Evens',
      number: 9,
      kind: 'differentEven',
      ways: 0,
      note: 'Hopeless, and the tile says so. Even parts add up to an even '
          'number, whatever they are and however many, and nine is odd: none '
          'of its 30 partitions has even parts throughout, let alone all '
          'different, while eight sunders into different even parts two '
          'ways, 8 and 6 + 2, and ten three ways, 10, 8 + 2 and 6 + 4.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
