import 'bridge.dart';

/// The nights that ship.
///
/// The Famous Four are the four everybody has met, at one, two, five and ten
/// minutes, and the answer is seventeen: the two slowest cross together, so
/// their ten and five cost ten once rather than fifteen twice. Ferrying
/// everybody over with the fastest walker costs nineteen, and the whole game
/// is those two minutes.
class Bridges {
  const Bridges._();

  static const all = <Bridge>[
    Bridge(
      name: 'Two of Us',
      walkers: [Walker('Nan', 1), Walker('Wat', 10)],
      fewest: 10,
      ferryDoes: true,
    ),
    Bridge(
      name: 'Three Abreast',
      walkers: [Walker('Nan', 1), Walker('Meg', 2), Walker('Wat', 5)],
      fewest: 8,
      ferryDoes: true,
    ),
    Bridge(
      name: 'The Famous Four',
      walkers: [
        Walker('Nan', 1),
        Walker('Meg', 2),
        Walker('Sim', 5),
        Walker('Wat', 10),
      ],
      fewest: 17,
    ),
    Bridge(
      name: 'The Even Pace',
      walkers: [
        Walker('Nan', 2),
        Walker('Meg', 3),
        Walker('Sim', 4),
        Walker('Wat', 5),
      ],
      fewest: 16,
      ferryDoes: true,
    ),
    Bridge(
      name: 'Five at the Wath',
      walkers: [
        Walker('Nan', 1),
        Walker('Meg', 2),
        Walker('Sim', 5),
        Walker('Wat', 10),
        Walker('Old Bel', 15),
      ],
      fewest: 28,
    ),
    Bridge(
      name: 'The Whole Household',
      walkers: [
        Walker('Nan', 1),
        Walker('Meg', 3),
        Walker('Sim', 8),
        Walker('Wat', 9),
        Walker('Old Bel', 10),
      ],
      fewest: 29,
    ),
  ];

  static int get count => all.length;

  static Bridge at(int number) => all[number.clamp(0, all.length - 1)];
}
