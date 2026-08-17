import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two and the Three',
      beads: 3,
      first: 2,
      second: 3,
      ways: 2,
      aim: [0, 1, 0],
      note: 'Two and three force a repeat of one at four beads, so three '
          'beads is the longest strip that can have both without it. Two of '
          'the eight strips do it, light dark light and its opposite.',
    ),
    Level(
      name: 'The Three and the Five',
      beads: 6,
      first: 3,
      second: 5,
      ways: 2,
      aim: [0, 1, 0, 0, 1, 0],
      note: 'Three and five force a repeat of one at seven beads. At six '
          'there are two strips with both repeats and no repeat of one, '
          'light dark light light dark light and its opposite, which is the '
          'Fibonacci strip of that length.',
    ),
    Level(
      name: 'The Four and the Six',
      beads: 7,
      first: 4,
      second: 6,
      ways: 4,
      aim: [0, 0, 0, 1, 0, 0, 0],
      note: 'Four and six share a divisor of two, so the length they force '
          'it at is eight rather than ten. At seven beads four strips have '
          'both repeats without repeating every two, and they come in two '
          'pairs, each strip and its opposite.',
    ),
    Level(
      name: 'The Five and the Eight',
      beads: 11,
      first: 5,
      second: 8,
      ways: 2,
      aim: [0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0],
      note: 'Five and eight are Fibonacci numbers, and the strip that has '
          'both repeats without a repeat of one is the longest such strip '
          'there is for its two repeats: eleven beads, one short of the '
          'twelve at which they would force it. Two strips of the 2,048 do '
          'it.',
    ),
    Level(
      name: 'One Too Long',
      beads: 7,
      first: 3,
      second: 5,
      ways: 0,
      aim: [],
      note: 'Hopeless, and the card at the end of the ask says so. Three and '
          'five have a greatest common divisor of one, so their bound is '
          'three plus five less one, which is seven. A strip of seven beads '
          'with both repeats has every bead the same, and then it repeats '
          'every one as well. Six beads is the longest that can dodge it, '
          'and none of the 128 strips of seven manages.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
