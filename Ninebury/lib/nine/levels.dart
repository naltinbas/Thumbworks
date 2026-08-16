import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Nine',
      kind: 'nine',
      ways: 84,
      note: 'Of the 1,000 numbers the dials reach, 111 have root nine, the '
          'multiples of nine, one in nine, as the roots share the numbers '
          'out evenly, 111 to each root from 1 to 9 and nought to 0 alone. '
          'Eighty-four of the multiples show three different digits, 42 '
          'adding to nine, from 018 up, and 42 adding to eighteen, and none '
          'to twenty-seven, since three different digits add to 24 at most.',
    ),
    Level(
      name: 'The Square Seven',
      kind: 'square7',
      ways: 7,
      note: 'The 32 squares to 961 have roots 0, 1, 4, 7 and 9 only, and seven '
          'of them root 7: 16, 25, 169, 196, 484, 529 and 961, the squares of '
          '4, 5, 13, 14, 22, 23 and 31, whose own roots are 4 or 5, and 4 '
          'times 4 is 16 and 5 times 5 is 25, root 7 both. A square\'s root is '
          'the root of its root squared.',
    ),
    Level(
      name: 'The Cube Eight',
      kind: 'cube8',
      ways: 3,
      note: 'The ten cubes to 729 have roots 0, 1, 8 and 9 only: 1, 8, 27, 64, '
          '125, 216, 343, 512 and 729 root 1, 8, 9, 1, 8, 9, 1, 8, 9 in turn, '
          'since a number\'s root runs 1 to 9 and the cubes of those root 1, '
          '8, 9, 1, 8, 9, 1, 8, 9. Three cubes root 8: 8, 125 and 512, the '
          'cubes of 2, 5 and 8.',
    ),
    Level(
      name: 'The Slip',
      kind: 'slip',
      ways: 110,
      note: '47 times 18 is 846: 47 roots 2, 18 roots 9, 2 times 9 is 18, root '
          '9, and 846 roots 9, as the check demands. But 110 wrong answers '
          'root 9 too, every ninth number, 864 with the last two digits '
          'swapped among them, and 837 and 855, nine either side: casting out '
          'nines catches a slip of any amount but a multiple of nine, and '
          'never a swapped pair of digits.',
    ),
    Level(
      name: 'The Square Five',
      kind: 'square5',
      ways: 0,
      note: 'Hopeless, and the tile says so. A square\'s root is the root of '
          'its root squared, and the roots 1 to 9 square to 1, 4, 9, 16, 25, '
          '36, 49, 64 and 81, roots 1, 4, 9, 7, 7, 9, 4, 1 and 9: five never '
          'comes, nor 2, 3, 6 or 8. All 32 squares to 961 bear it out, and 4 '
          'and 7, either side of five, are as near as a square\'s root comes.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
