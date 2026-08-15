import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static final all = <Level>[
    Level(
      name: 'The Two',
      order: 1,
      ways: 2,
      note: 'The kite of order one is a square of four cells, and it slates '
          'two ways, both across or both down: two to the one.',
    ),
    Level(
      name: 'The Eight',
      order: 2,
      ways: 8,
      note: 'Twelve cells in rows of two, four, four and two, and eight '
          'slatings: two to the three. Every one lays an even count of '
          'slates across, nought, two, four or six, and one, three, three '
          'and one of them do.',
    ),
    Level(
      name: 'The Two Across',
      order: 2,
      acrossAsked: 2,
      ways: 3,
      note: 'Three of the eight slatings lay exactly two slates across, and '
          'three lay four; one lays none and one lays six: one, three, three, '
          'one, a row of Pascal\'s triangle. The order after runs 1, 6, 15, '
          '20, 15, 6, 1 over nought to twelve across, and the one after that '
          'the row of ten, and every count of slates across is even.',
    ),
    Level(
      name: 'The Sixty-Four',
      order: 3,
      ways: 64,
      note: 'Twenty-four cells in rows of two, four, six, six, four and two, '
          'and sixty-four slatings: two to the six. The order after has '
          '1,024 and the one after that 32,768, every one of them laid out '
          'and counted.',
    ),
    Level(
      name: 'The One Across',
      order: 2,
      acrossAsked: 1,
      ways: 0,
      note: 'Hopeless, and the tile says so. Every row of the kite has an '
          'even count of cells, so the slates hanging down out of a row '
          'are even in number, row by row from the top, and the slates '
          'lying across are what is left of an even count: even too. One '
          'across never comes: none of the eight slatings has it.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
