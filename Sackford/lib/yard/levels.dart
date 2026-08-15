import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Two Carts',
      sacks: [6, 4, 3, 3, 2, 2],
      carts: 2,
      ways: 2,
      note: 'Twenty stone in two carts of ten: two loadings do it, the six with '
          'the four and the rest together, or the six with two twos and the four '
          'with the threes; the carrier\'s rule finds the first.',
    ),
    Level(
      name: 'The Three Carts',
      sacks: [6, 5, 5, 4, 4, 4, 2],
      carts: 3,
      ways: 1,
      note: 'Thirty stone in three carts, every cart full to the brim, and one '
          'loading only, the six with a four, the fives together and the other '
          'fours with the two; the carrier\'s rule finds it.',
    ),
    Level(
      name: 'The Tight Load',
      sacks: [7, 6, 5, 4, 3, 2, 1, 1, 1],
      carts: 3,
      ways: 5,
      note: 'Nine sacks, thirty stone, three carts full to the brim: five '
          'loadings, the seven with the three or with a two and a one or with '
          'three ones, the six with the four or with a two and two ones or with a '
          'three and a one, and the five taking what is left; the carrier\'s rule '
          'finds the seven with the three, the six with the four.',
    ),
    Level(
      name: 'Where the Carrier Slips',
      sacks: [7, 5, 4, 4, 3, 3, 2, 2],
      carts: 3,
      ways: 1,
      note: 'Thirty stone in three carts, and one loading only, the seven with a '
          'three, the five with the other three and a two, the fours with the '
          'other two; but the carrier\'s rule, '
          'heaviest first into the first cart with room, drops the seven with a '
          'three and the five with a four and is left with a two for a fourth '
          'cart, one more than the fewest; of the 3,003 loads of six sacks of one '
          'to nine stone it needs a cart too many on four.',
    ),
    Level(
      name: 'The Thirty-One',
      sacks: [8, 7, 6, 5, 3, 2],
      carts: 3,
      ways: 0,
      note: 'Thirty-one stone, and three carts carry thirty: the weight over ten '
          'rounded up is four carts, a floor no loading beats, on any of the '
          '3,003 loads of six either; four carts take these ten ways.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
