import 'level.dart';

/// The five harvests that ship.
///
/// Every number here is checked before the bake: every partition
/// walked, Euler's identity and Glaisher's turn held to the walk, and
/// tool/check_stooks.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Seven Apart',
      sheaves: 7,
      kind: 'apart',
      ways: 5,
      partitions: 15,
      note: 'Seven sheaves stand fifteen ways, and five of them in stooks all '
          'of different sizes: 7; 6 and 1; 5 and 2; 4 and 3; 4, 2 and 1. Five '
          'ways too in stooks all odd, and Euler says the two counts agree '
          'for every harvest there is.',
    ),
    Level(
      name: 'The Seven Odd',
      sheaves: 7,
      kind: 'odd',
      ways: 5,
      partitions: 15,
      note: 'Five ways: 7; 5, 1, 1; 3, 3, 1; 3, 1, 1, 1, 1; and seven ones. '
          'Glaisher turns each into one of the five apart, pairing equal '
          'stooks into double ones until none match: 3, 3, 1 becomes 6 and 1, '
          'and seven ones become 4, 2 and 1.',
    ),
    Level(
      name: 'The Ten Apart',
      sheaves: 10,
      kind: 'apart',
      ways: 10,
      partitions: 42,
      note: 'Ten of the 42 partitions of ten have stooks all of different '
          'sizes, and ten have stooks all odd; one of the ten apart is 4, 3, '
          '2, 1, the smallest harvest that stands in four different stooks.',
    ),
    Level(
      name: 'The Twelve Odd',
      sheaves: 12,
      kind: 'odd',
      ways: 15,
      partitions: 77,
      note: 'Fifteen of the 77 partitions of twelve are all odd stooks, and '
          'fifteen are all different, as Euler says: the products (1 + x)(1 + '
          'x squared)(1 + x cubed)... and 1 over (1 - x)(1 - x cubed)(1 - x to '
          'the fifth)... are the same series, checked here to sixty sheaves.',
    ),
    Level(
      name: 'The Four Stooks of Nine',
      sheaves: 9,
      kind: 'apart',
      stooks: 4,
      ways: 0,
      partitions: 30,
      note: 'Four stooks of different sizes hold at the least 1, 2, 3 and 4 '
          'sheaves, ten in all, and nine is one short. Every one of the 30 '
          'partitions of nine was walked to be sure: eight are all apart, and '
          'none of those has four stooks.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
