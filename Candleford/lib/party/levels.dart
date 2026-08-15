import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Even Chance',
      days: 365,
      num: 1,
      den: 2,
      strict: true,
      cap: 366,
      ways: 1,
      note: 'Twenty-three guests make a shared birthday more likely than not, '
          '50.7297 in a hundred, and twenty-two fall short at 47.5695; ten guests '
          'have 11.6948, thirty 70.6316, and the pairs of guests, 253 at '
          'twenty-three, are what do it, not the guests.',
    ),
    Level(
      name: 'Nine in Ten',
      days: 365,
      num: 9,
      den: 10,
      cap: 366,
      ways: 1,
      note: 'Forty-one guests reach nine in ten, 90.3151 in a hundred, and forty '
          'stop at 89.1231; fifty have 97.0373.',
    ),
    Level(
      name: 'Ninety-Nine in a Hundred',
      days: 365,
      num: 99,
      den: 100,
      cap: 366,
      ways: 1,
      note: 'Fifty-seven guests reach ninety-nine in a hundred, 99.0122, and '
          'fifty-six stop at 98.8332; sixty have 99.4122, and a hundred 99.9999 '
          'and something, still not certain.',
    ),
    Level(
      name: 'The Shared Month',
      days: 12,
      num: 1,
      den: 2,
      strict: true,
      cap: 13,
      ways: 1,
      note: 'Five guests make a shared birth month more likely than not, 61.8055 '
          'in a hundred, and four fall short at 42.7083; twelve guests reach '
          '99.9946 and thirteen make it certain, since twelve months cannot hold '
          'thirteen guests apart.',
    ),
    Level(
      name: 'The Certain Day',
      days: 365,
      num: 1,
      den: 1,
      cap: 365,
      ways: 0,
      note: 'Fewer than 366 guests never make a shared birthday certain: 365 of '
          'them can have one birthday each, and the chance of no two sharing, '
          '365 times 364 times on down to one over 365 to the 365th, is a '
          'number 779 digits long over one 936 digits long, small past telling '
          'and not nought; the 366th guest has no day left, and then it is '
          'certain.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
