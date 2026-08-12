import 'hall.dart';

/// The five halls that ship.
///
/// Every number here is checked twice before the bake: the sweep
/// posts every watch of every hall, the three-colouring builds its
/// own, and tool/check_halls.dart refuses the lot if anything
/// disagrees.
class Halls {
  static const all = [
    Hall(
      name: 'The Ell',
      corners: [(0, 0), (6, 0), (6, 2), (2, 2), (2, 5), (0, 5)],
      asked: 1,
      fewest: 1,
      note: 'One ward at the inner corner sees down both arms: the '
          'bend is the whole of this hall\'s trouble, and the bend '
          'is where the watch stands.',
    ),
    Hall(
      name: 'The Zigzag',
      corners: [
        (0, 0), (7, 0), (7, 4), (5, 4), (5, 2), (3, 2), (3, 5),
        (0, 5)
      ],
      asked: 2,
      fewest: 2,
      note: 'Two pockets fold away from each other, and no single '
          'corner sees into both: the sweep posts every one of the '
          'eight alone and the floor stays part dark.',
    ),
    Hall(
      name: 'The Spikes',
      corners: [
        (0, 0), (12, 0), (12, 1), (11, 6), (9, 1), (8, 6), (6, 1),
        (5, 6), (3, 1), (2, 6), (0, 1)
      ],
      asked: 2,
      fewest: 2,
      note: 'Four spikes and a watch of two: the spikes lean so '
          'that two low corners split them between themselves. '
          'The three-colouring posts three; the sweep shaves it '
          'to two, the roof standing above the floor.',
    ),
    Hall(
      name: 'The Comb',
      corners: [
        (0, 0), (9, 0), (9, 4), (8, 4), (8, 1), (6, 1), (6, 4),
        (4, 4), (4, 1), (2, 1), (2, 4), (0, 4)
      ],
      asked: 3,
      fewest: 3,
      note: 'Three teeth, three wards, a tooth apiece: here the '
          'colouring and the sweep meet exactly, the roof sitting '
          'flat on the floor.',
    ),
    Hall(
      name: 'The Comb Short',
      corners: [
        (0, 0), (9, 0), (9, 4), (8, 4), (8, 1), (6, 1), (6, 4),
        (4, 4), (4, 1), (2, 1), (2, 4), (0, 4)
      ],
      asked: 2,
      fewest: 3,
      note: 'The same comb, one ward fewer: the sweep posts all '
          'sixty-six pairs of corners and every one leaves a tooth '
          'part dark.',
    ),
  ];

  static int get count => all.length;

  static Hall at(int number) => all[number];
}
