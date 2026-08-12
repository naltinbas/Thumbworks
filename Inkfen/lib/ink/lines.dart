import 'line.dart';

/// The five lines that ship.
///
/// Every number here is checked before the bake: the sweeps,
/// the alternation law, the matching law on the full four, and
/// tool/check_inks.dart refuses the lot if anything disagrees.
class Lines {
  static const all = [
    Line(
      name: 'The Two-Ink Path',
      spots: [
        (0.08, 0.62),
        (0.29, 0.38),
        (0.5, 0.58),
        (0.71, 0.36),
        (0.92, 0.55),
      ],
      strings: [(0, 1), (1, 2), (2, 3), (3, 4)],
      pot: 2,
      ways: 2,
      note: 'Two ways only: pick the first string\'s ink and '
          'the rest is forced, string by string down the path.',
    ),
    Line(
      name: 'The Even Ring',
      spots: [
        (0.5, 0.1),
        (0.85, 0.3),
        (0.85, 0.7),
        (0.5, 0.9),
        (0.15, 0.7),
        (0.15, 0.3),
      ],
      strings: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0)],
      pot: 2,
      ways: 2,
      note: 'The even ring alternates home: two ways again, one '
          'per opening ink, and six strings come back right.',
    ),
    Line(
      name: 'The Full Four',
      spots: [
        (0.2, 0.2),
        (0.8, 0.2),
        (0.8, 0.8),
        (0.2, 0.8),
      ],
      strings: [(0, 1), (1, 2), (2, 3), (3, 0), (0, 2), (1, 3)],
      pot: 3,
      ways: 6,
      note: 'Every landing splits the six strings into the '
          'three perfect matchings, one ink each: six ways is '
          'exactly the orders three inks take.',
    ),
    Line(
      name: 'The Ring Mended',
      spots: [
        (0.5, 0.08),
        (0.9, 0.4),
        (0.75, 0.88),
        (0.25, 0.88),
        (0.1, 0.4),
      ],
      strings: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)],
      pot: 3,
      ways: 30,
      note: 'One ink more mends the odd ring: thirty inkings '
          'land, and every one wears some ink exactly once, '
          'since no ink fits three strings of five round a '
          'ring.',
    ),
    Line(
      name: 'The Odd Ring',
      spots: [
        (0.5, 0.08),
        (0.9, 0.4),
        (0.75, 0.88),
        (0.25, 0.88),
        (0.1, 0.4),
      ],
      strings: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)],
      pot: 2,
      ways: 0,
      note: 'Drop any one string and two inks land the other '
          'four, both ways of the path: it is only the coming '
          'home that fails.',
    ),
  ];

  static int get count => all.length;

  static Line at(int number) => all[number];
}
