import 'level.dart';

/// The five asks, first to last. Each count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'Seventy',
      fillings: 70,
      ways: 2,
      fewest: 1,
      note: 'Two of the 22 staircases have 70 fillings, and they are each '
          'other turned on their side: 4, 3, 1 and 3, 2, 2, 1. Turning a '
          'staircase over swaps its rows for its columns and so swaps every '
          'hook for another hook of the same staircase, which is why the two '
          'always come out with the same count.',
    ),
    Level(
      name: 'Ninety',
      fillings: 90,
      ways: 1,
      fewest: 2,
      note: 'One staircase of the 22, 4, 2, 1, 1, and no staircase of eight '
          'boxes has more fillings. Its hooks are 7, 4, 2, 1, 4, 1, 2, 1, '
          'which multiply to 448, and 40320 over 448 is 90.',
    ),
    Level(
      name: 'Fourteen',
      fillings: 14,
      ways: 2,
      fewest: 2,
      note: 'Two of the 22, the square 4, 4 and the tall 2, 2, 2, 2, again '
          'each other turned on their side. Fourteen is the Catalan number '
          'for four, which is what a staircase of two equal rows always '
          'counts: the fillings are the ways of never letting the bottom row '
          'get ahead of the top.',
    ),
    Level(
      name: 'The Single File',
      fillings: 1,
      ways: 2,
      fewest: 5,
      note: 'Two of the 22, and the furthest apart of any pair: all eight in '
          'a row, or all eight in a column. Either way the numbers have only '
          'one order they can go in, and the hooks are 8, 7, 6, 5, 4, 3, 2, '
          '1, which multiply to 40320 exactly.',
    ),
    Level(
      name: 'Against the Hooks',
      fillings: 0,
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Every one '
          'of the 22 staircases was counted twice before the sham was built, '
          'once by taking the largest number off a corner and counting what '
          'is left, and once by dividing eight factorial by the hooks, and '
          'the two agree every time. They agree for staircases of nine boxes '
          'and ten as well. There is nothing to find.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
