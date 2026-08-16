import 'level.dart';

/// The five asks, first to last. Every count is the sieve's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Product Tells',
      kind: 'tells',
      ways: 605,
      note: 'Of the 2,352 pairs, 605 have a product that splits one way '
          'only into two numbers from 2 up with a sum of 100 at most, and P '
          'knows them at once: 6 is 2 times 3 and nothing else, and so is '
          'the product of any two primes; the other 1,747 leave him in the '
          'dark.',
    ),
    Level(
      name: 'The Sum That Knew',
      kind: 'knew',
      ways: 145,
      note: 'Ten sums let S say she knew P did not know, every split of them '
          'leaving him in the dark: 11, 17, 23, 27, 29, 35, 37, 41, 47 and '
          '53, odd every one, none of them two more than a prime, and 145 '
          'pairs add to one of them; an even sum never serves, since it '
          'splits into two different primes and their product tells P.',
    ),
    Level(
      name: 'The Product Then Knew',
      kind: 'then',
      ways: 86,
      note: 'Once S has spoken, P looks at the splits of his product and '
          'keeps those whose sum is one of her ten: 86 of the 145 pairs '
          'leave him exactly one, 2 and 9 the first, since 18 is 2 times 9 '
          'or 3 times 6, and 11 is one of the ten sums while 9 is not.',
    ),
    Level(
      name: 'The Sum Then Knew',
      kind: 'both',
      ways: 1,
      note: 'S looks at the splits of her sum and keeps those whose product '
          'P could now know from, and one sum of the ten keeps exactly one '
          'split, 17 with 4 and 13: the sums 11, 23 and 27 keep 3, 3 and 9, '
          'and none but 17 keeps one. Freudenthal set the puzzle in 1969, '
          'and 4 and 13 is the whole of its answer.',
    ),
    Level(
      name: 'The Even Sum',
      kind: 'even',
      ways: 0,
      note: 'Hopeless, and the tile says so. Every even sum from 8 to 100 '
          'splits into two different primes, as Goldbach guessed and the '
          'sieve checks, and the product of two primes splits no other way, '
          'so P would know at once from that split and S could never say '
          'she knew he did not; 6 splits only into 2 and 4, whose product 8 '
          'tells P too, and 4 does not split at all. Of the 145 pairs whose '
          'sum lets S speak, none has an even sum.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
