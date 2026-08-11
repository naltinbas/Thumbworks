import 'party.dart';

/// The parties that ship.
///
/// Every number here is checked twice over: tool/check_parties.dart
/// sweeps every pairing of each and refuses the bake if a written
/// figure is wrong, and the suite runs the asking-round besides.
class Parties {
  static const all = [
    Party(
      name: 'The Three Couples',
      names: ['Ada', 'Bea', 'Cy', 'Kit', 'Lou', 'Mo'],
      prefs: [
        [3, 4, 5],
        [4, 3, 5],
        [4, 5, 3],
        [0, 1, 2],
        [1, 2, 0],
        [2, 0, 1],
      ],
      sided: true,
      settles: 1,
      note: 'Of the fifteen ways to wed six people, exactly one '
          'settles, and the old asking-round walks straight to it.',
    ),
    Party(
      name: 'The Latin Party',
      names: ['Ada', 'Bea', 'Cy', 'Dot', 'Kit', 'Lou', 'Mo', 'Nan'],
      prefs: [
        [4, 5, 6, 7],
        [5, 6, 7, 4],
        [6, 7, 4, 5],
        [7, 4, 5, 6],
        [1, 2, 3, 0],
        [2, 3, 0, 1],
        [3, 0, 1, 2],
        [0, 1, 2, 3],
      ],
      sided: true,
      settles: 4,
      note: 'Tastes run in a ring, and four different pairings settle '
          'it: any one of the four is a win. The asking-round finds the '
          'one the askers like best.',
    ),
    Party(
      name: 'The Mild House',
      names: ['Ada', 'Bea', 'Cy', 'Dot'],
      prefs: [
        [1, 2, 3],
        [0, 3, 2],
        [3, 0, 1],
        [2, 1, 0],
      ],
      sided: false,
      settles: 1,
      note: 'Ada and Bea put each other first, and the other two make '
          'the best of it: one settled pairing in the three.',
    ),
    Party(
      name: 'The Six of Us',
      names: ['Ada', 'Bea', 'Cy', 'Dot', 'Eli', 'Fay'],
      prefs: [
        [1, 2, 3, 4, 5],
        [0, 2, 4, 3, 5],
        [3, 1, 0, 5, 4],
        [2, 4, 0, 1, 5],
        [3, 0, 1, 5, 2],
        [4, 0, 2, 3, 1],
      ],
      sided: false,
      settles: 1,
      note: 'Fifteen ways to pair six housemates, and the sweep finds '
          'exactly one that settles. Show me knows it.',
    ),
    Party(
      name: 'The Odd House',
      names: ['Ada', 'Bea', 'Cy', 'Dot'],
      prefs: [
        [1, 2, 3],
        [2, 0, 3],
        [0, 1, 3],
        [0, 1, 2],
      ],
      sided: false,
      settles: 0,
      note: 'Ada wants Bea, Bea wants Cy, Cy wants Ada, and nobody '
          'wants Dot. Whoever is wedded to Dot is somebody\'s first '
          'choice, and that somebody will always leave for them: all '
          'three pairings break, and the sweep has watched each one do '
          'it.',
    ),
  ];

  static int get count => all.length;

  static Party at(int number) => all[number];
}
