import 'worth.dart';

/// The five worths that ship.
///
/// Every number here is checked before the bake: the balance,
/// the sweep and the crate counting, and tool/check_beams.dart
/// refuses the lot if anything disagrees.
class Worths {
  static const all = [
    Worth(
      name: 'The Three',
      choose: 3,
      ways: 206,
      note: 'Three weights go clean 206 ways of the 220: only '
          'the near-misses like 1 and 2 against 3 spoil a '
          'handful this small.',
    ),
    Worth(
      name: 'The Four',
      choose: 4,
      ways: 331,
      note: 'Four is the yard\'s roomiest asking: 331 of the '
          '495 choices keep every parcel to its own weight.',
    ),
    Worth(
      name: 'The Five',
      choose: 5,
      ways: 142,
      note: 'The room narrows: 142 clean fives, and every one '
          'leans on the heavy end of the rack.',
    ),
    Worth(
      name: 'The Six',
      choose: 6,
      ways: 1,
      note: 'One clean six in the whole yard: 11, 17, 20, 22, '
          '23 and 24, a set built weight by weight so that no '
          'two parcels ever agree.',
    ),
    Worth(
      name: 'The Seventh Weight',
      choose: 7,
      ways: 0,
      note: 'Counting alone bars it: seven weights make 127 '
          'parcels with something in them, and no seven of this '
          'rack weigh past 125 together, so two parcels must '
          'share a reading. The sweep tried all 792 choices and '
          'found the clash in every one.',
    ),
  ];

  static int get count => all.length;

  static Worth at(int number) => all[number];
}
