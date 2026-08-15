import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Four by Four',
      side: 4,
      queens: 2,
      ways: 12,
      placings: 120,
      aim: [0, 10],
      note: 'Two queens watch the four by four in 12 of the 120 placings, '
          'and one never: a queen sees 12 squares at the most there, from '
          'the middle four, and 10 from a corner. The a4 and c2 pair is one '
          'of the twelve.',
    ),
    Level(
      name: 'The Six by Six',
      side: 6,
      queens: 3,
      ways: 4,
      placings: 7140,
      aim: [0, 16, 26],
      note: 'Three queens watch the six by six in only 4 of the 7,140 '
          'placings: a6 e4 c2, f6 b4 d2, c5 e3 a1 and d5 b3 f1, one shape '
          'turned four ways. Two queens never do, 6 squares unseen at the '
          'best of the 630.',
    ),
    Level(
      name: 'The Chessboard',
      side: 8,
      queens: 5,
      ways: 4860,
      placings: 7624512,
      aim: [0, 1, 13, 32, 44],
      note: 'Five queens watch the whole chessboard in 4,860 of the '
          '7,624,512 placings of five, every one of the placings tried and '
          'every watching set found again by picking a queen for the first '
          'unseen square in turn. Four queens never do.',
    ),
    Level(
      name: 'The Nearest Miss',
      side: 8,
      queens: 4,
      unseenAsked: 2,
      ways: 64,
      placings: 635376,
      aim: [0, 12, 39, 57],
      note: 'Four queens leave two squares unseen in 64 of the 635,376 '
          'placings, and no placing leaves fewer: none of the 635,376 sees '
          'the whole board, 672 leave three unseen, and a8 e7 h4 b1 is one '
          'of the 64 that leave two.',
    ),
    Level(
      name: 'The Lone Queen',
      side: 4,
      queens: 1,
      ways: 0,
      placings: 16,
      aim: null,
      note: 'Hopeless, and the tile says so. One queen on the four by four '
          'sees her row, her column and her slants: 12 squares from any of '
          'the middle four, 10 from a corner, and never 16. Four of the '
          'sixteen squares come nearest, leaving four unseen.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
