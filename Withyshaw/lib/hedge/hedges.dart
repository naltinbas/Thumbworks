import 'hedge.dart';

/// The hedges that ship.
///
/// The worths climb from whole withies to quarters, and the Even Hedge
/// is the famous nought: a half, a half, and a minus one, exactly
/// nothing, where whoever cuts first loses and the first cut is yours.
/// It ships labelled, in the house tradition of maps nobody can win.
class Hedges {
  const Hedges._();

  static final List<Hedge> all = [
    Hedge(
      name: 'The First Withy',
      stalks: const [(0x1, 2)],
      winnable: true,
      note: 'One stalk, your withy under the hedger\'s. Cut yours and '
          'everything above it falls: the hedger is left with nothing to '
          'cut, and a stalk like this is worth exactly a half.',
    ),
    Hedge(
      name: 'The Whole and the Half',
      stalks: const [(0x3, 2), (0x2, 2)],
      winnable: true,
      note: 'Two of yours on one stalk, the hedger\'s under yours on the '
          'other: two, less a half. The hedge is worth one and a half, '
          'and it is yours however the cutting goes.',
    ),
    Hedge(
      name: 'The Last Quarter',
      stalks: const [(0x5, 3), (0x2, 2)],
      winnable: true,
      note: 'Three quarters against a half the other way: the whole '
          'hedge is worth one quarter. That quarter is the entire '
          'margin, and one careless cut spends it.',
    ),
    Hedge(
      name: 'The Even Hedge',
      stalks: const [(0x1, 2), (0x1, 2), (0x0, 1)],
      winnable: false,
      note: 'A half, a half, and a whole one of the hedger\'s: exactly '
          'nought. At nought, whoever must cut first loses, and the '
          'first cut is yours. This hedge is here to be felt, not held.',
    ),
    Hedge(
      name: 'The Long Hedge',
      stalks: const [(0x3, 3), (0x2, 2), (0x5, 3), (0x0, 1)],
      winnable: true,
    ),
  ];

  static int get count => all.length;

  static Hedge at(int number) => all[number.clamp(0, all.length - 1)];
}
