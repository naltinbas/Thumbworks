import 'rota.dart';

/// The five rotas that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every finishing, the symmetries held to it, every fill of three
/// and four shifts swept, and tool/check_rotas.dart refuses the
/// lot if anything disagrees.
class Rotas {
  static const all = [
    Rota(
      name: 'The First Day',
      fixed: {(0, 0): 1, (0, 1): 2, (0, 2): 3, (0, 3): 4},
      ways: 24,
      note: 'With the first day fixed, 24 rotas finish it, and 24 '
          'times the 24 orders of the first day is 576, every rota '
          'of four there is.',
    ),
    Rota(
      name: 'The Three Fixed',
      fixed: {(0, 0): 1, (1, 1): 2, (2, 2): 3},
      ways: 8,
      note: 'Every sound fill of three shifts finishes, all 25,920 '
          'of them, in 8, 16 or 24 ways; this one in 8.',
    ),
    Rota(
      name: 'The Diagonal',
      fixed: {(0, 0): 1, (1, 1): 2, (2, 2): 3, (3, 3): 4},
      ways: 2,
      note: 'The four hands down the diagonal leave two rotas, and '
          'each is the other with days and stations swapped, read '
          'across the diagonal itself.',
    ),
    Rota(
      name: 'The Four Fixed',
      fixed: {(0, 0): 1, (0, 1): 2, (1, 0): 2, (2, 2): 3},
      ways: 1,
      note: 'Four shifts can pin a rota to one finishing, and these '
          'do; four shifts can also spoil it, and 13,824 of the '
          '239,760 sound fills of four never finish.',
    ),
    Rota(
      name: 'The Stuck Shift',
      fixed: {(0, 0): 1, (0, 1): 2, (0, 2): 3, (1, 3): 4},
      ways: 0,
      note: 'The last shift of the first day can take neither 1, 2 '
          'nor 3, who work that day already, nor 4, who works that '
          'station on the second day: no hand is left for it, and '
          'the sweep of 4,096 hands over the twelve open shifts '
          'confirms it.',
    ),
  ];

  static int get count => all.length;

  static Rota at(int number) => all[number];
}
