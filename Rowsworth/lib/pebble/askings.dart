import 'asking.dart';

/// The five askings that ship.
///
/// Every number here is checked before the bake: the sweep of the
/// board by trial, the powers held to it, and tool/check_rows.dart
/// refuses the lot if anything disagrees.
class Askings {
  static const all = [
    Asking(
      name: 'The Seven Rows',
      rows: 7,
      heaps: [64],
      note: 'Seven is prime, so seven even rows need one prime to the '
          'sixth: sixty-four alone of the hundred, and the next is '
          'seven hundred and twenty-nine.',
    ),
    Asking(
      name: 'The Nine Rows',
      rows: 9,
      heaps: [36, 100],
      note: 'Nine is three times three: two primes squared, thirty-six '
          'and a hundred, or one prime to the eighth, two hundred and '
          'fifty-six, off the board.',
    ),
    Asking(
      name: 'The Ten Rows',
      rows: 10,
      heaps: [48, 80],
      note: 'Ten is five times two: a prime to the fourth times another, '
          'forty-eight and eighty, or a prime to the ninth, five hundred '
          'and twelve.',
    ),
    Asking(
      name: 'The Twelve Rows',
      rows: 12,
      heaps: [60, 72, 84, 90, 96],
      note: 'Sixty is the smallest heap with twelve even rows, and the '
          'records up to a hundred run 1, 2, 4, 6, 12, 24, 36, 48 and '
          '60; seventy-two, eighty-four, ninety and ninety-six tie it.',
    ),
    Asking(
      name: 'The Thirteen Rows',
      rows: 13,
      heaps: [],
      note: 'Thirteen is prime, so it is one power raised by one and '
          'nothing else: a single prime to the twelfth, and two to the '
          'twelfth is four thousand and ninety-six, the smallest heap '
          'anywhere with thirteen even rows.',
    ),
  ];

  static int get count => all.length;

  static Asking at(int number) => all[number];
}
