import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two Thirds',
      want: (2, 3),
      ways: 12,
      note: 'Bertrand\'s own laying, gold and gold, gold and silver, silver '
          'and silver, gives 2 in 3, and so does every laying with one '
          'gold pair and one mixed coffer, twelve of the 64: three gold '
          'coins can be drawn, and two of them, the pair, have a gold mate. '
          'The pull towards a half comes from counting coffers, two that '
          'could hold the gold coin, when the draw counts coins, and the '
          'pair holds two of the three.',
    ),
    Level(
      name: 'The Half',
      want: (1, 2),
      ways: 12,
      note: 'A half wants twice as many mixed coffers as gold pairs: one pair '
          'and two mixed, four gold coins, two of them with a gold mate, '
          'twelve layings of the 64 by which coffer holds the pair and '
          'which way round the mixed ones lie. It never comes with three '
          'gold coins, since one pair leaves one mixed coffer, and that is '
          '2 in 3.',
    ),
    Level(
      name: 'The Four Fifths',
      want: (4, 5),
      ways: 6,
      note: 'Two gold pairs and one mixed coffer: five gold coins, four of '
          'them with a gold mate, 4 in 5, six layings of the 64. The '
          'chances the six coins can give are 0, 1/2, 2/3, 4/5 and 1, and '
          'nothing else: 26 layings give 0, 12 a half, 12 two thirds, 6 four '
          'fifths, 7 certainty, and one, all silver, no gold coin to draw.',
    ),
    Level(
      name: 'The Certain',
      want: (1, 1),
      ways: 7,
      note: 'Certainty wants no mixed coffer at all and one gold pair at '
          'least: one pair and two silver pairs three ways, two pairs and '
          'one silver pair three ways, and three gold pairs one way, seven '
          'layings of the 64.',
    ),
    Level(
      name: 'The Half of Three',
      want: (1, 2),
      golds: 3,
      ways: 0,
      note: 'Hopeless, and the tile says so. Three gold coins fill one coffer '
          'at most: if they do, two of the three have a gold mate and the '
          'chance is 2 in 3, and if they do not, each coffer holds one gold '
          'coin with a silver mate and the chance is 0. The sweep of the 20 '
          'layings of three gold and three silver finds 2 in 3 twelve times '
          'and 0 eight times, and a half never.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
