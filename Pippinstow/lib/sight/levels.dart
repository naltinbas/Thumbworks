import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Far Row',
      kind: 'far',
      ways: 4,
      note: 'Of the ten trees in the tenth row four are in sight, at files '
          '1, 3, 7 and 9, the files that share no factor with ten; of all '
          'a hundred trees 63 are in sight and 37 hidden, and the tree at '
          '(1, 1) hides nine, the whole diagonal.',
    ),
    Level(
      name: 'The Twice Hidden',
      kind: 'twice',
      ways: 7,
      note: 'A tree hidden behind exactly two others has file and row three '
          'times a pair that share no factor: seven trees, (3, 3), (3, 6), '
          '(3, 9), (6, 3), (6, 9), (9, 3) and (9, 6); nineteen trees are '
          'hidden behind one, three behind three, and (10, 10) behind '
          'nine.',
    ),
    Level(
      name: 'The Long Shadow',
      kind: 'shadow',
      ways: 2,
      note: 'A tree in sight hides its multiples: (1, 2) hides (2, 4), (3, '
          '6), (4, 8) and (5, 10), and (2, 1) the same turned about, the '
          'two trees that hide four; (1, 1) alone hides nine, four trees '
          'hide two, twelve hide one, and 44 of the 63 in sight hide none.',
    ),
    Level(
      name: 'The Deep Corner',
      kind: 'deep',
      ways: 10,
      note: 'Of the sixteen trees with file and row seven or more, ten are '
          'in sight, from (8, 7) to (9, 10), and six hidden, (7, 7), (8, 8), '
          '(9, 9), (10, 10), (8, 10) and (10, 8), each behind a nearer tree '
          'on its line.',
    ),
    Level(
      name: 'The Hidden Edge',
      kind: 'edge',
      ways: 0,
      note: 'Hopeless, and the tile says so. A tree in the first row stands '
          'one step up, and any tree on the line to it would stand less '
          'than one step up, which no tree does; the same across for the '
          'first file, and one and any number share no factor but one. Of '
          'the nineteen trees on the two edges every one is in sight, and '
          'the sweep finds a tree hidden exactly when its file and row '
          'share a factor, on all a hundred.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
