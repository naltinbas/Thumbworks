import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two Plots',
      pieces: 2,
      even: false,
      ways: 2,
      fewest: 6,
      note: 'Two cuts of the field do it, and they are the two diagonals. '
          'Both come out nine half acres and nine, so with two plots the '
          'sizes are equal whether you ask for it or not. Hold on to that: '
          'even at two, forced at six, and impossible at three is the whole '
          'of this game.',
    ),
    Level(
      name: 'The Three Plots',
      pieces: 3,
      even: false,
      ways: 32,
      fewest: 9,
      note: '32 cuts of the field do it. Every single one of them comes out '
          '3, 6 and 9 half acres, because a cut into three always leaves one '
          'plot standing on a whole side of the field, and a whole side is '
          'half the field. Every one of the 32 has exactly one motley plot, '
          'the sort with a corner of each colour.',
    ),
    Level(
      name: 'The Six Plots',
      pieces: 6,
      even: false,
      ways: 8836,
      fewest: 18,
      note: '8,836 cuts of the field do it, which is most of the ways six '
          'plots can be laid at all. Sizes are free here, so the ask is only '
          'that nothing overlaps and nothing is left over. It is the loosest '
          'ask in the game and the one that teaches the hand.',
    ),
    Level(
      name: 'The Even Six',
      pieces: 6,
      even: true,
      ways: 68,
      fewest: 18,
      note: '68 cuts of the 8,836 give six plots of 3 half acres apiece. An '
          'even number of equal plots is always to be had, and six is the '
          'first even number past two that divides the field. Compare it '
          'with the ask that follows, which wants three of 6 half acres and '
          'cannot have them.',
    ),
    Level(
      name: 'The Even Three',
      pieces: 3,
      even: true,
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Monsky '
          'proved in 1970 that a square cuts into no odd number of equal '
          'triangles at all, whether or not the corners land on pegs. Here '
          'it can be seen twice over on the board. Every one of the 32 '
          'three-plot cuts has a plot of 9 half acres, half the field, which '
          'is not a third of it. And colour each peg from its own two '
          'numbers: every one of those 32 cuts has exactly one motley plot, '
          'motley plots always come out an odd number of half acres, and 6 '
          'is not odd.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
