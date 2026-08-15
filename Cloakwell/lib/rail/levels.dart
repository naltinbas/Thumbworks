import 'level.dart';

/// The five rails that ship.
///
/// Every number here is checked before the bake: every sequence swept,
/// the pairs out of order held to the search, and tool/check_swaps.dart
/// refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Two Askew',
      row: [2, 1, 4, 3],
      swaps: 2,
      ways: 2,
      sequences: 9,
      note: 'Two pairs hang out of order, 2 before 1 and 4 before 3, and a '
          'swap of neighbours can mend one pair at most: two swaps, either '
          'pair first, 2 of the 9 sequences of two.',
    ),
    Level(
      name: 'The Reverse of Four',
      row: [4, 3, 2, 1],
      swaps: 6,
      ways: 16,
      sequences: 729,
      note: 'Every pair of the four hangs out of order, six pairs, so six '
          'swaps at the least; 16 of the 729 sequences of six sort them, each '
          'a way of writing the full reverse as six swaps of neighbours.',
    ),
    Level(
      name: 'The Middle Out',
      row: [2, 4, 1, 5, 3],
      swaps: 4,
      ways: 5,
      sequences: 256,
      note: 'Four pairs out of order, 2 and 1, 4 and 1, 4 and 3, 5 and 3, and '
          '5 of the 256 sequences of four swaps mend them all; every swap that '
          'sorts must swap a coat with a smaller neighbour on its right.',
    ),
    Level(
      name: 'The Reverse of Five',
      row: [5, 4, 3, 2, 1],
      swaps: 10,
      ways: 768,
      sequences: 1048576,
      note: 'Ten pairs, ten swaps, and 768 of the 1,048,576 sequences of ten '
          'sort them; the fewest swaps is the count of pairs out of order for '
          'every row of up to six coats, all 873 rows searched.',
    ),
    Level(
      name: 'The Five Swaps',
      row: [4, 3, 2, 1],
      swaps: 5,
      ways: 0,
      sequences: 243,
      note: 'Six pairs hang out of order and a swap of neighbours changes that '
          'count by exactly one, up or down, so five swaps leave at least one '
          'pair askew, and an odd count of swaps leaves an odd count of pairs '
          'besides. None of the 243 sequences of five sorts the four.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
