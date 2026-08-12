import 'cake.dart';

/// The five cakes that ship.
///
/// Every number here is checked before the bake: both slice
/// counts on every pick there is, the formula where nothing
/// clumps, and tool/check_slices.dart refuses the lot if
/// anything disagrees.
class Cakes {
  static const all = [
    Cake(
      name: 'The Eight',
      candles: 4,
      slices: 8,
      ways: 495,
      note: 'Four candles cut eight however they stand: no '
          'four spots of this rim ever clump a crossing, so '
          'the doubling holds at every pick.',
    ),
    Cake(
      name: 'The Sixteen',
      candles: 5,
      slices: 16,
      ways: 792,
      note: 'Five candles cut sixteen however they stand, and '
          'the doubling looks like a law: one, two, four, '
          'eight, sixteen. It is not.',
    ),
    Cake(
      name: 'The Thirty-One',
      candles: 6,
      slices: 31,
      ways: 856,
      note: 'The doubling breaks: not thirty-two but '
          'thirty-one, one plus fifteen lines plus fifteen '
          'crossings, every crossing picking its own four '
          'candles.',
    ),
    Cake(
      name: 'The Thirty',
      candles: 6,
      slices: 30,
      ways: 68,
      note: 'Sixty-eight picks clump three knife lines through '
          'one point, and the clump pays two slices where '
          'spread crossings pay three: thirty, one fewer '
          'still.',
    ),
    Cake(
      name: 'The Thirty-Two',
      candles: 6,
      slices: 32,
      ways: 0,
      note: 'Slices are one, plus a line apiece, plus a '
          'crossing apiece: six candles hang fifteen lines, '
          'crossings pick four candles each for fifteen at '
          'the most, and clumping only loses. Thirty-one is '
          'the ceiling.',
    ),
  ];

  static int get count => all.length;

  static Cake at(int number) => all[number];
}
