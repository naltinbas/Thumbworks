import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Fair Wait',
      kind: 'fair',
      ways: 1,
      note: 'Of the 1,711 timetables of three buses an hour, one alone gives '
          'the fair wait of 9 1/2 minutes, the gaps 20, 20 and 20: within a '
          'gap of twenty the waits run 19 down to 0, adding to 190, and the '
          'sixty minutes share three such, 570 minutes of waiting in an '
          'hour.',
    ),
    Level(
      name: 'The Fourteen and a Half',
      kind: 'half',
      ways: 3,
      note: 'The gaps 10, 10 and 40, in any order, give an average wait of '
          '14 1/2 minutes, five over the fair, though the buses are as many: '
          'the wide gap holds forty of the sixty minutes and its waits run '
          'to 39. Only these three timetables and the fair one give a wait '
          'that ends in a half, and no timetable gives a whole number of '
          'minutes.',
    ),
    Level(
      name: 'The Quarter Hour',
      kind: 'quarter',
      ways: 555,
      note: 'A third of the timetables, 555 of 1,711, make the average '
          'passenger wait a quarter hour or more, and 165 of them twenty '
          'minutes or more, three buses an hour notwithstanding; 171 have '
          'two buses a minute apart.',
    ),
    Level(
      name: 'The Worst Timetable',
      kind: 'worst',
      ways: 3,
      note: 'The longest average wait is 27 11/20 minutes, from the gaps 1, '
          '1 and 58 in any order: two buses a minute apart and the third '
          'fifty-eight minutes on, so that fifty-eight of the sixty minutes '
          'fall in the wide gap, waiting up to 57.',
    ),
    Level(
      name: 'The Short Wait',
      kind: 'under',
      ways: 0,
      note: 'Hopeless, and the tile says so. The waiting in an hour adds up '
          'gap by gap to half of each gap squared less half the gap, and '
          'the squares of three gaps adding to sixty add to 1,200 at least, '
          'since the average of squares is never below the square of the '
          'average, with equality only when the gaps are equal: so the '
          'waiting is 570 minutes at least and the average wait 9 1/2, and '
          'the sweep of all 1,711 timetables finds none below it. Feller '
          'set the paradox down in 1966: bunch the buses and the average '
          'passenger waits longer, never shorter, and it never runs the '
          'other way.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
