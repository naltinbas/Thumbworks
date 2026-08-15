import 'level.dart';

/// The five ledgers that ship.
///
/// Every number here is checked before the bake: every keeping of the
/// rows swept for every pair up to sixty by sixty, the rule held to the
/// sweep, and tool/check_keepings.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'Thirteen by Seven',
      first: 13,
      second: 7,
      ways: 1,
      keepings: 16,
      note: 'Thirteen halves to six, three and one, and seven doubles to '
          'fourteen, twenty-eight and fifty-six; the odd halves are thirteen, '
          'three and one, and their doubles, seven, twenty-eight and fifty-six, '
          'add to ninety-one, thirteen sevens. Sixteen keepings of the four rows, '
          'and that one alone lands.',
    ),
    Level(
      name: 'Twenty-Seven by Nineteen',
      first: 27,
      second: 19,
      ways: 1,
      keepings: 32,
      note: 'Twenty-seven halves to thirteen, six, three and one; the odd rows '
          'are the first, second, fourth and fifth, and their doubles, 19, 38, '
          '152 and 304, add to 513. One keeping of the thirty-two.',
    ),
    Level(
      name: 'Forty by Twenty-Five',
      first: 40,
      second: 25,
      ways: 1,
      keepings: 64,
      note: 'Forty halves to twenty, ten, five, two and one, and only five and '
          'one are odd: their doubles, 200 and 800, make the thousand, forty '
          'being thirty-two and eight. One keeping of the sixty-four.',
    ),
    Level(
      name: 'Ninety-Nine by Nine',
      first: 99,
      second: 9,
      ways: 1,
      keepings: 128,
      note: 'Ninety-nine halves to 49, 24, 12, 6, 3 and 1: seven rows, and the '
          'odd halves are 99, 49, 3 and 1, whose doubles 9, 18, 288 and 576 add '
          'to 891, since ninety-nine is 64 and 32 and 2 and 1. One keeping of '
          'the 128.',
    ),
    Level(
      name: 'Thirteen by Seven in Two',
      first: 13,
      second: 7,
      exactly: 2,
      ways: 0,
      keepings: 6,
      note: 'The doubles are 7, 14, 28 and 56, and the two biggest make 84, '
          'short of 91; no two rows land, and the six pairs were swept. '
          'Ninety-one wants three rows, since thirteen is eight and four and '
          'one, three twos.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
