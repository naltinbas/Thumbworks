import 'errand.dart';

/// The five errands that ship.
///
/// Every number here is checked before the bake: the ride over
/// every standing, the ring held to it, and
/// tool/check_paddocks.dart refuses the lot if anything disagrees.
class Errands {
  static const all = [
    Errand(
      name: 'The Errand',
      asked: Asked.paleOneBottomLeft,
      fewest: 3,
      rides: 2,
      note: 'Three moves at the fewest, two rides: pale one goes round '
          'the ring one way or the other, and a dark steed steps aside '
          'for it.',
    ),
    Errand(
      name: 'The Quarter Turn',
      asked: Asked.quarterTurn,
      fewest: 8,
      rides: 1088,
      note: 'Every steed one corner on, clockwise: eight moves at the '
          'fewest, two apiece, and 1,088 fewest rides.',
    ),
    Errand(
      name: 'The Pales Down',
      asked: Asked.palesDown,
      fewest: 13,
      rides: 71680,
      note: 'Both pale steeds in the bottom corners, the dark ones '
          'anywhere: thirteen moves at the fewest and 71,680 fewest '
          'rides.',
    ),
    Errand(
      name: 'The Colour Swap',
      asked: Asked.colourSwap,
      fewest: 16,
      rides: 4726784,
      note: 'Guarini\'s puzzle of 1512: sixteen moves at the fewest, '
          '4,726,784 fewest rides, and it comes out one way only, each '
          'steed in the corner across from its own, since the other '
          'swap breaks the order round the ring; sixteen is as far from '
          'home as any standing lies.',
    ),
    Errand(
      name: 'The Pale Swap',
      asked: Asked.paleSwap,
      fewest: 0,
      rides: 0,
      note: 'Round the ring the steeds run pale one, dark three, dark '
          'four, pale two, and every knight\'s move keeps that order; '
          'the two pale ones swapped would run pale two, dark three, '
          'dark four, pale one, another order, and the ride from home '
          'reaches 280 standings, all with the first order, never the '
          'second.',
    ),
  ];

  static int get count => all.length;

  static Errand at(int number) => all[number];
}
