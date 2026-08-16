import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Square of Seven',
      number: 49,
      fromOne: true,
      ways: 1,
      note: 'The odd numbers from 1 add up to squares: 1, 4, 9, 16 and on, '
          'each new odd number an L of dots round the last square, and '
          'seven of them, 1 to 13, make 49, seven squared. Every count of '
          'them from 1 to 20 makes the count squared, 400 for twenty, and '
          'no other run from 1 makes 49; 49 alone, a run of one, does.',
    ),
    Level(
      name: 'The Twenty-One',
      number: 21,
      ways: 2,
      note: 'Twenty-one is 5 + 7 + 9, the square of five less the square of '
          'two, 25 less 4, and 21 alone, the square of eleven less the '
          'square of ten: two runs. A run of consecutive odd numbers is '
          'always the difference of two squares, the outer square\'s side '
          'the inner\'s and the count together, and an odd number is always '
          'a run of one.',
    ),
    Level(
      name: 'The Sixty-Four',
      number: 64,
      ways: 3,
      note: 'Sixty-four is 31 + 33, 13 + 15 + 17 + 19 and 1 + 3 + ... + 15, '
          'eight from 1: three runs, the squares 16 less 15, 10 less 6 and 8 '
          'less nothing. A run with an even count adds to a multiple of '
          'four, since its odd numbers pair off, each pair a multiple of '
          'four; 48, 72 and 80 have three runs each too, and 96 four, the '
          'most of any number to a hundred.',
    ),
    Level(
      name: 'The Hundred',
      number: 100,
      ways: 2,
      note: 'A hundred is 1 + 3 + ... + 19, ten from 1, ten squared, and '
          '49 + 51, the square of 26 less the square of 24: two runs. Four '
          'consecutive odd numbers add to a multiple of eight, 16, 24, 32 '
          'and on, never a hundred, and five to five times the middle one, '
          'never a hundred either, since the middle would be twenty and '
          'even.',
    ),
    Level(
      name: 'The Thirty',
      number: 30,
      ways: 0,
      note: 'Hopeless, and the tile says so. An odd count of odd numbers adds '
          'to an odd number, and an even count pairs off, each pair of '
          'neighbouring odd numbers a multiple of four, so the sum is a '
          'multiple of four: thirty, two past a multiple of four, is '
          'neither, and nor is 2, 6, 10 or any number two past a multiple '
          'of four. The sweep of all 1,000 runs on the dials makes 28 and 32 '
          'and never 30.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
