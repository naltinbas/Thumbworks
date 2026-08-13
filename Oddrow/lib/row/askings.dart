import 'asking.dart';

/// The five askings that ship.
///
/// Every number here is checked before the bake: the addition,
/// the bit rule and the doubling agree on every row of the
/// wall, and tool/check_rows.dart refuses the lot if anything
/// disagrees.
class Askings {
  static const all = [
    Asking(
      name: 'The Two Odds',
      odds: 2,
      ways: 4,
      note: 'The four rows are one, two, four and eight: a '
          'lone lit bit doubles once, and the two odds sit at '
          'the row\'s two ends.',
    ),
    Asking(
      name: 'The Four Odds',
      odds: 4,
      ways: 6,
      note: 'Six rows hold four odds, every one a row with two '
          'lit bits: three, five, six, nine, ten and twelve.',
    ),
    Asking(
      name: 'The Eight Odds',
      odds: 8,
      ways: 4,
      note: 'Three lit bits double three times: seven, eleven, '
          'thirteen and fourteen each light eight.',
    ),
    Asking(
      name: 'The Full Row',
      odds: 16,
      ways: 1,
      note: 'Row fifteen alone lights everything: all four '
          'bits lit, every place\'s bits fit, and the triangle '
          'above it draws its own lace.',
    ),
    Asking(
      name: 'The Three Odds',
      odds: 3,
      ways: 0,
      note: 'Every lit bit of the row doubles the choices for '
          'an odd place, so the count runs one, two, four, '
          'eight, sixteen: three is no power of two, and no '
          'row anywhere holds it.',
    ),
  ];

  static int get count => all.length;

  static Asking at(int number) => all[number];
}
