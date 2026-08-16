import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Half Dozen',
      kind: 'sixMedian',
      ways: 1,
      aim: (6, 13),
      note: 'A set of six takes 147/10 packets on average, 14.7, but it is '
          'more likely full than not from the thirteenth packet, 0.51 to '
          '0.43 after twelve: one setting of the 720. The average and the '
          'coin-toss point differ because the long tail of unlucky albums '
          'drags the average out.',
    ),
    Level(
      name: 'The Twelve',
      kind: 'twelveLikely',
      ways: 26,
      aim: (12, 35),
      note: 'A set of twelve takes 86,021/2,310 packets on average, 37.23, '
          'and is more likely full than not from the thirty-fifth packet: '
          'packets 35 to 60 land it, 26 settings of the 720. The coin-toss '
          'points run 1, 2, 5, 7, 10, 13, 17, 20, 23, 27, 31 and 35 for sets '
          'of one to twelve.',
    ),
    Level(
      name: 'The Whole Average',
      kind: 'whole',
      ways: 120,
      aim: (1, 1),
      note: 'One sticker takes one packet and two take three on average, '
          'and no set from three to twelve averages a whole number: three '
          'take 11/2, four 25/3, five 137/12, up to 86,021/2,310 for twelve; '
          'so 120 settings of the 720, the sets of one and two with any '
          'packets.',
    ),
    Level(
      name: 'The Last Sticker',
      kind: 'last',
      ways: 180,
      aim: (3, 1),
      note: 'The last sticker of a set of n takes n packets on average, and '
          'the rest together take n times the harmonic number less n: for '
          'one, two and three stickers the last outweighs the rest, 3 to 5/2 '
          'for three, and from four up it does not, 4 to 13/3; 180 settings '
          'of the 720.',
    ),
    Level(
      name: 'The Certain Album',
      kind: 'certain',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. With two stickers or more the '
          'same sticker could come in every packet, so no count of packets '
          'makes the album certain: a set of six is short after sixty '
          'packets one time in ten thousand, 0.99 full, and never one; a '
          'set of one is full at the first packet, and it alone is certain.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
