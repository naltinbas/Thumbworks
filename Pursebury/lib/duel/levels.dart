import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Quarter',
      kind: 'chance',
      want: (1, 4),
      ways: 2,
      aim: (1, 3, 1),
      note: 'With the fair coin Ash takes the pot as often as his share of '
          'it: one coin to Birch\'s three, or two to six, is a quarter, 2 '
          'settings of 108. Neither crooked coin makes a quarter exactly: '
          'they give chances with 2 to the pot less 1 under, an odd number, '
          'and a quarter would need four times something.',
    ),
    Level(
      name: 'The Two to One',
      kind: 'chance',
      want: (2, 3),
      ways: 4,
      aim: (2, 1, 1),
      note: 'Two thirds is Ash\'s share at two coins to one, four to two or '
          'six to three with the fair coin, and it comes once more with the '
          'coin for him: one coin each, when a coin of two in three takes '
          'the pot two times in three, 4 settings of 108.',
    ),
    Level(
      name: 'The Nine Tosses',
      kind: 'lasts',
      want: (9, 1),
      ways: 1,
      aim: (3, 3, 1),
      note: 'A fair duel lasts as many tosses on average as the two purses '
          'multiplied: three coins each is 9, the one setting of 108, and no '
          'crooked coin lasts a whole nine. Two coins each with the coin '
          'for Ash lasts 18/5, three coins to one against him 17/5.',
    ),
    Level(
      name: 'The Long Purse',
      kind: 'atLeast',
      want: (9, 20),
      coin: 0,
      ways: 4,
      aim: (3, 1, 0),
      note: 'With the coin against him Ash\'s chance is 2 to his purse less 1 '
          'over 2 to the pot less 1: one coin to Birch\'s one is a third, two '
          'to one 3/7, three to one 7/15, then 15/31, 31/63 and 63/127, '
          'nearer and nearer to a half and never there. Three coins to one '
          'and up reach nine in twenty, 4 settings of 108.',
    ),
    Level(
      name: 'The Even Duel Against the Coin',
      kind: 'chance',
      want: (1, 2),
      coin: 0,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. With the coin against him Ash\'s '
          'chance is 2 to his purse less 1 over 2 to the pot less 1, and a '
          'half would need the number under to be twice the number over: 2 '
          'to the pot less 1 is odd, and an odd number is never twice '
          'anything. None of the 108 settings lands it, and the nearest is '
          'six coins to one, 63/127.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
