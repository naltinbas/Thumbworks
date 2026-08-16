import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Level Line',
      kind: 'level',
      ways: 452,
      note: 'The three crossings stand at one height for 452 of the 14,168 '
          'hexagons the rails hold, counted once each whichever way round '
          'the pegs are named: bottom 0, 1, 2 with top 0, 1, 2 puts them at '
          '(1/2, 3), (1, 3) and (3/2, 3), while bottom 0, 2, 5 with top 1, '
          '4, 6 has them rising, (8/5, 12/5), (3, 3) and (22/5, 18/5), still '
          'in a line. Every hexagon on the rails is Pappus\'s: 85,008 '
          'orderings of the pegs cross at three points, and not one bends.',
    ),
    Level(
      name: 'The Middle Rung',
      kind: 'middle',
      ways: 196,
      note: 'When the crossings stand level they may stand at half height, 3, '
          'and 196 of the 452 do: bottom 0, 1, 2 with top 0, 1, 2, or 1, 2, '
          '3, or 2, 3, 4, and every hexagon whose top three are its bottom '
          'three shifted along, since a join and its swap then meet halfway '
          'up whatever the shift.',
    ),
    Level(
      name: 'The Whole Points',
      kind: 'whole',
      ways: 908,
      note: 'The three crossings all fall on pegs for 908 of the 14,168: '
          'bottom 0, 1, 2 with top 1, 2, 0 puts them at (1, 3), (0, 12) and '
          '(2, -6), far above and below the rails and in a line down through '
          'the middle rung, since a crossing may stand anywhere on the '
          'plane, above the top rail, below the bottom or between.',
    ),
    Level(
      name: 'The Steep Line',
      kind: 'steep',
      ways: 16,
      note: 'Only 16 hexagons of the 14,168 stand their three crossings one '
          'above another, the line through them straight up: bottom 0, 2, 3 '
          'with top 0, 6, 3 at (3/2, 3/2), (3/2, 3) and (3/2, -3), and bottom '
          '0, 2, 6 with top 3, 2, 6 at (4, 12), (4, 4) and (4, 3).',
    ),
    Level(
      name: 'The Bent Line',
      kind: 'bent',
      ways: 0,
      note: 'Hopeless, and the tile says so. Pappus of Alexandria proved it '
          'around the year 340, the earliest theorem of the projective kind: '
          'whatever three pegs on each rail, the three crossings of the '
          'cross-joins lie on one line. The sweep of all 112,896 orderings '
          'of three pegs on each rail finds 85,008 whose cross-joins all '
          'cross, 14,168 hexagons counted once each, and not one of them '
          'bent.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
