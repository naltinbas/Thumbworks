import 'hill.dart';

/// The five hills that ship.
///
/// Every number here is checked before the bake: the census, the
/// rim walk and the sweep, and tool/check_hills.dart refuses the
/// lot if anything disagrees.
class Hills {
  static const all = [
    Hill(
      name: 'The First Patch',
      side: 3,
      asked: 1,
      ways: 2,
      opens: 'B',
      note: 'One planting spot and three plants to try in it: two '
          'of the three plantings settle at a single patch, and '
          'the third jumps straight to three, because two was '
          'never on offer.',
    ),
    Hill(
      name: 'The Five',
      side: 4,
      asked: 5,
      ways: 3,
      note: 'Three spots to plant and 27 ways to plant them: '
          'exactly three of the 27 push the hill to five patches, '
          'its most.',
    ),
    Hill(
      name: 'The Nine',
      side: 5,
      asked: 9,
      ways: 16,
      note: 'Six spots, 729 plantings, and the patch count runs '
          '1, 3, 5, 7, 9, 11 with never an even step: sixteen '
          'plantings land nine.',
    ),
    Hill(
      name: 'The Eleven',
      side: 5,
      asked: 11,
      ways: 1,
      note: 'The needle of the whole hillside: of all 729 '
          'plantings, exactly one shows eleven patches, and the '
          'sweep knows which.',
    ),
    Hill(
      name: 'The Even Hill',
      side: 4,
      asked: 2,
      ways: 0,
      note: 'Sperner\'s lemma, walked on the rim: the fixed '
          'boundary carries exactly one bracken-gorse edge, and '
          'the patch count always matches that walk\'s parity. '
          'Odd, every time: the sweep of all 27 plantings found '
          'counts of one, three and five and nothing else, and '
          'the same holds at every size swept.',
    ),
  ];

  static int get count => all.length;

  static Hill at(int number) => all[number];
}
