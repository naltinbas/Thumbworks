import 'low.dart';

/// The five lows that ship.
///
/// Every number here is checked before the bake: the gap census,
/// the sweep and the complement, and tool/check_lows.dart
/// refuses the lot if anything disagrees.
class Lows {
  static const all = [
    Low(
      name: 'The Path of Four',
      posts: 4,
      lines: [(0, 1), (1, 2), (2, 3)],
      spots: [(0.1, 0.5), (0.37, 0.35), (0.63, 0.6), (0.9, 0.4)],
      ways: 4,
      note: 'Four numberings grace the path, and they pair off '
          'twice over: read backwards, or turn every mark to '
          'three-less-it, and a graceful numbering stays '
          'graceful.',
    ),
    Low(
      name: 'The Star',
      posts: 4,
      lines: [(0, 1), (0, 2), (0, 3)],
      spots: [(0.5, 0.5), (0.5, 0.12), (0.16, 0.75), (0.84, 0.75)],
      ways: 12,
      note: 'The hub takes nought or three and the leaves take '
          'the rest any way round: twelve graceful numberings, '
          'the most a shape here carries but one.',
    ),
    Low(
      name: 'The Square',
      posts: 4,
      lines: [(0, 1), (1, 2), (2, 3), (0, 3)],
      spots: [(0.25, 0.25), (0.75, 0.25), (0.75, 0.75), (0.25, 0.75)],
      ways: 16,
      note: 'A ring of four graces sixteen ways: its four gaps '
          'must sum even, and one to four sums to ten, which '
          'obliges. The ring of five is another story.',
    ),
    Low(
      name: 'The Path of Five',
      posts: 5,
      lines: [(0, 1), (1, 2), (2, 3), (3, 4)],
      spots: [
        (0.08, 0.5), (0.29, 0.32), (0.5, 0.58), (0.71, 0.36),
        (0.92, 0.52),
      ],
      ways: 8,
      note: 'Eight numberings grace the longer path: every path '
          'takes one at any length, which is the easy half of a '
          'conjecture still open for trees at large.',
    ),
    Low(
      name: 'The Five Ring',
      posts: 5,
      lines: [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4)],
      spots: [
        (0.5, 0.12), (0.88, 0.4), (0.73, 0.85), (0.27, 0.85),
        (0.12, 0.4),
      ],
      ways: 0,
      note: 'Round any ring the gaps sum even: each gap shares '
          'its evenness with the sum of its two ends, and going '
          'round, every post is counted twice. But gaps of 1 to '
          '5 must sum to fifteen, which is odd: the five-ring '
          'never graces, and the sweep of all 720 numberings '
          'agrees.',
    ),
  ];

  static int get count => all.length;

  static Low at(int number) => all[number];
}
