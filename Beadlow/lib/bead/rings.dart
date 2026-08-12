import 'ring.dart';

/// The five rings that ship.
///
/// Every number here is checked twice before the bake: the counting
/// and the shelf are held against each other, and
/// tool/check_rings.dart refuses the lot if anything disagrees.
class Rings {
  static const all = [
    Ring(
      name: 'The Three',
      beads: 3,
      dyes: 2,
      asked: 4,
      holds: 4,
      note: 'Two solid strings and two mixed: turning makes one '
          'necklace of amber-amber-bone however the ring sits.',
    ),
    Ring(
      name: 'The Five',
      beads: 5,
      dyes: 2,
      asked: 8,
      holds: 8,
      note: 'Five is prime, so every mixed string turns five ways: '
          'thirty mixed strings fold to six necklaces, and the two '
          'solids stand alone.',
    ),
    Ring(
      name: 'The Three of Three',
      beads: 3,
      dyes: 3,
      asked: 11,
      holds: 11,
      note: 'Twenty-seven strings fold to eleven: three solids, and '
          'twenty-four mixed folding by threes to eight.',
    ),
    Ring(
      name: 'The Fourteen',
      beads: 6,
      dyes: 2,
      asked: 14,
      holds: 14,
      note: 'The six turns fix 64, 2, 4, 8, 4 and 2 strings each: '
          'eighty-four over six is fourteen, and the shelf says the '
          'same one string at a time.',
    ),
    Ring(
      name: 'The Seventh',
      beads: 4,
      dyes: 2,
      asked: 7,
      holds: 6,
      note: 'Sixteen strings fold to six necklaces and no more: '
          'the four turns fix 16, 2, 4 and 2, and twenty-four over '
          'four is six.',
    ),
  ];

  static int get count => all.length;

  static Ring at(int number) => all[number];
}
