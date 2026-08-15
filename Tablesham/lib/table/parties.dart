import 'party.dart';

/// The five parties that ship.
///
/// Every number here is checked before the bake: the sweep and
/// Touchard's arithmetic at every size, and
/// tool/check_tables.dart refuses the lot if anything
/// disagrees.
class Parties {
  static const all = [
    Party(
      name: 'The Three Couples',
      couples: 3,
      ways: 1,
      note: 'One seating alone parts all three couples, and it '
          'turns the whole table one way: every husband three '
          'seats round from his wife, past the next wife\'s '
          'chair.',
    ),
    Party(
      name: 'The Four Couples',
      couples: 4,
      ways: 2,
      note: 'Two seatings part four couples, and they are '
          'mirrors of one another: the whole table turned three '
          'seats one way, or three seats the other.',
    ),
    Party(
      name: 'The Seated Host',
      couples: 5,
      given: (2, 0),
      ways: 5,
      note: 'With the host held in his chair, the thirteen '
          'seatings of five narrow to five, and one of the five '
          'turns the whole table as one, every husband two gaps '
          'round from his own.',
    ),
    Party(
      name: 'The Five Couples',
      couples: 5,
      ways: 13,
      note: 'Thirteen seatings part five couples. Three of them '
          'turn the whole table as one, every husband the same '
          'count of gaps round from his own; the other ten '
          'do not.',
    ),
    Party(
      name: 'The Two Couples',
      couples: 2,
      ways: 0,
      note: 'The two seatings of two couples were both swept, '
          'and each seats both couples together, two quarrels '
          'apiece and never just one.',
    ),
  ];

  static int get count => all.length;

  static Party at(int number) => all[number];
}
