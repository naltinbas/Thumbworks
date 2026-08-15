import 'level.dart';

/// The five yards that ship.
///
/// Every number here is checked before the bake: every ordering of
/// every yard walked, Redei's insertion and Camion's ring held to
/// every yard of up to six, and tool/check_bouts.dart refuses the lot
/// if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Four',
      wrestlers: 4,
      bouts: [(0, 1), (0, 3), (2, 0), (2, 1), (3, 1), (3, 2)],
      ring: false,
      ways: 3,
      orderings: 24,
      note: 'Ash, Cole and Dane threw two apiece and Bram nobody, and Ash '
          'threw Dane, Dane threw Cole, Cole threw Ash, round in a circle. '
          'Three of the 24 orderings line up, one for each way into the '
          'circle, and Bram is last in every one.',
    ),
    Level(
      name: 'The Five',
      wrestlers: 5,
      bouts: [(0, 2), (0, 3), (1, 0), (2, 1), (3, 1), (3, 2), (4, 0), (4, 1), (4, 2), (4, 3)],
      ring: false,
      ways: 5,
      orderings: 120,
      note: 'Eli threw all four, so every line starts with Eli; the other '
          'four line up five ways behind him, and 5 of the 120 orderings '
          'land it. Redei\'s slotting finds one with no search: Ash first, '
          'Bram in front of him having thrown him, Cole in front of Bram, '
          'Dane in front of Cole, Eli in front of all.',
    ),
    Level(
      name: 'The Ring',
      wrestlers: 5,
      bouts: [(0, 1), (0, 4), (1, 3), (2, 0), (2, 1), (3, 0), (3, 2), (4, 1), (4, 2), (4, 3)],
      ring: true,
      ways: 10,
      orderings: 120,
      note: 'Every wrestler here can be reached from every other along the '
          'throws, and Camion says such a yard always closes into a ring: '
          'this one has two rings, ten orderings of the 120 counting where '
          'you start, and thirteen lines.',
    ),
    Level(
      name: 'The Six',
      wrestlers: 6,
      bouts: [(0, 1), (0, 5), (1, 3), (2, 0), (2, 1), (3, 0), (3, 2), (4, 0), (4, 1), (4, 2), (4, 3), (5, 1), (5, 2), (5, 3), (5, 4)],
      ring: false,
      ways: 23,
      orderings: 720,
      note: 'Six wrestlers, fifteen bouts, and 23 of the 720 orderings line '
          'up. Twenty-three is odd, as Redei says every yard\'s count is: '
          'across all 32,768 yards of six the count is never even.',
    ),
    Level(
      name: 'The Champion\'s Ring',
      wrestlers: 5,
      bouts: [(0, 2), (0, 3), (1, 0), (2, 1), (3, 1), (3, 2), (4, 0), (4, 1), (4, 2), (4, 3)],
      ring: true,
      ways: 0,
      orderings: 120,
      note: 'The same yard as The Five: it lines up five ways, but nobody '
          'threw Eli, so nobody can stand before him in a ring, and the ring '
          'never closes. Camion says the same from the far side: a yard '
          'rings exactly when every wrestler can be reached from every '
          'other, and nobody reaches Eli.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
