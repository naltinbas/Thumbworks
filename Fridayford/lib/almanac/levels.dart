import 'level.dart';

/// The five asks that ship.
///
/// Every number here is checked before the bake: all fourteen kinds of
/// year swept, the offsets of the thirteenths held to cover the week,
/// and two hundred real years walked day by day by the phone's own
/// calendar; tool/check_years.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'One Friday',
      count: 1,
      ways: 6,
      kinds: 14,
      note: 'Six kinds of year have one Friday the thirteenth: common years '
          'beginning on a Wednesday, Friday or Saturday, and leap years '
          'beginning on a Tuesday, Friday or Saturday.',
    ),
    Level(
      name: 'Two Fridays',
      count: 2,
      ways: 6,
      kinds: 14,
      startDay: 2,
      note: 'Six kinds have two: common years beginning on a Monday, Tuesday or '
          'Sunday, and leap years beginning on a Monday, Wednesday or Thursday.',
    ),
    Level(
      name: 'Three Fridays',
      count: 3,
      ways: 2,
      kinds: 14,
      note: 'Two kinds have three, and none has more: a common year beginning '
          'on a Thursday, with Fridays in February, March and November, and a '
          'leap year beginning on a Sunday, with January, April and July.',
    ),
    Level(
      name: 'A Friday in November',
      count: -1,
      month: 10,
      ways: 2,
      kinds: 14,
      note: 'The thirteenth of November is a Friday in a common year beginning '
          'on a Thursday and in a leap year beginning on a Wednesday: two kinds '
          'of the fourteen, one for each length of February.',
    ),
    Level(
      name: 'No Friday',
      count: 0,
      ways: 0,
      kinds: 14,
      note: 'The thirteenths of the twelve months fall, counting from the '
          'first of January, nought, three, three, six, one, four, six, two, '
          'five, nought, three and five days along the week in a common year, '
          'and nought, three, four, nought, two, five, nought, three, six, one, '
          'four and six in a leap year: every day of the week is among them '
          'either way, so whatever day the year begins some thirteenth is a '
          'Friday. All fourteen kinds were swept, and two hundred real years '
          'walked day by day.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
