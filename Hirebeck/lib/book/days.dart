import 'day.dart';

/// The days that ship.
///
/// Every number here is checked twice over: tool/check_days.dart
/// sweeps every choice of hirings and strikes the piercing o'clocks,
/// and refuses the bake on any disagreement.
class Days {
  static const all = [
    Day(
      name: 'The Quiet Morning',
      guests: ['the choir', 'the weavers', 'the whist', 'the bees',
          'the players'],
      starts: [8, 9, 11, 13, 16],
      ends: [10, 12, 13, 17, 18],
      ask: 3,
      fullest: 3,
      ways: 2,
      note: 'Three of the five can share the day, two ways: the sweep '
          'of every choice says no fourth ever fits.',
    ),
    Day(
      name: 'The Trap Day',
      guests: ['the fair', 'the choir', 'the weavers', 'the whist',
          'the bees', 'the players'],
      starts: [8, 9, 12, 14, 16, 17],
      ends: [15, 11, 14, 17, 18, 20],
      ask: 4,
      fullest: 4,
      ways: 1,
      note: 'Book whoever asks earliest and the fair takes the '
          'morning whole: two hirings, and the book is shut. Book by '
          'earliest finish and four fit. The sweep counts exactly '
          'one full book.',
    ),
    Day(
      name: 'The Busy Day',
      guests: ['the choir', 'the bells', 'the weavers', 'the whist',
          'the bees', 'the players', 'the growers', 'the darts',
          'the supper'],
      starts: [8, 8, 9, 11, 12, 13, 14, 15, 17],
      ends: [10, 9, 12, 13, 14, 16, 18, 17, 19],
      ask: 5,
      fullest: 5,
      ways: 1,
      note: 'Nine guests, five places, one way to seat them all: the '
          'sweep of all 512 choices finds a single full book.',
    ),
    Day(
      name: 'The Long Fair',
      guests: ['the fair', 'the choir', 'the weavers', 'the whist',
          'the bees', 'the players', 'the growers', 'the supper'],
      starts: [8, 9, 10, 12, 13, 15, 16, 18],
      ends: [20, 11, 12, 14, 15, 17, 18, 20],
      ask: 4,
      fullest: 4,
      ways: 8,
      note: 'The fair wants the hall all day, and booking it first '
          'books one hiring only. Leave it out and four fit, eight '
          'ways over.',
    ),
    Day(
      name: 'The Extra Guest',
      guests: ['the fair', 'the choir', 'the weavers', 'the whist',
          'the bees', 'the players'],
      starts: [8, 9, 12, 14, 16, 17],
      ends: [15, 11, 14, 17, 18, 20],
      ask: 5,
      fullest: 4,
      ways: 1,
      note: 'Five bookings from the trap day\'s guests: the day '
          'cannot hold them. Four o\'clocks pierce every hiring, '
          'eleven, two, five and eight, and two guests holding the '
          'same o\'clock clash, so four is the ceiling. The sweep of '
          'every choice agrees.',
    ),
  ];

  static int get count => all.length;

  static Day at(int number) => all[number];
}
