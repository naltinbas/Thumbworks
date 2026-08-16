import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Climb',
      kind: 'climb',
      ways: 8154,
      aim: 'AAB',
      note: 'Both levers are fair on their own, and yet 8,154 of the 8,190 '
          'loops climb. Not one of them sinks. The 36 that stand still are '
          'the loops of one lever, A over and over or B over and over, and '
          'the loops that alternate, ABAB and BABA, which is the first '
          'pattern most people try.',
    ),
    Level(
      name: 'The Famous Loop',
      kind: 'famous',
      ways: 12,
      aim: 'ABB',
      note: 'A once and B twice is the loop Parrondo told it with, and it '
          'gains 2416/35601 of a coin a round, near enough a fifteenth. '
          'Twelve loops climb at exactly that rate: ABB, BAB and BBA, and '
          'each of those written out twice, three times and four.',
    ),
    Level(
      name: 'The Slower Four',
      kind: 'four',
      ways: 4,
      aim: 'AABB',
      note: 'The best a loop of four slots can do is 4/163, about a coin '
          'every forty rounds, which is slower than the best three-slot '
          'loop by a good deal. Four loops of four manage it, AABB and its '
          'three turns about. A longer loop is not a better one.',
    ),
    Level(
      name: 'The Best Loop',
      kind: 'best',
      ways: 10,
      aim: 'ABABB',
      note: 'The fastest climb of all is 3613392/47747645, a coin every '
          'thirteen rounds or so, and ten loops reach it: the five turnings '
          'of BBABA and those same five written out twice. It beats the '
          'famous ABB by about a ninth.',
    ),
    Level(
      name: 'One Lever Forever',
      kind: 'one',
      ways: 0,
      aim: '',
      note: 'Hopeless, and the board says so in red. A on its own is a coin '
          'toss and goes nowhere. B on its own settles on remainders 0, 1 '
          'and 2 in the shares 5/13, 2/13 and 6/13, so five times in '
          'thirteen it is the mean paying, which loses four fifths of a '
          'coin, and eight times in thirteen it is the kind one, which '
          'gains half a coin: 5 times 4/5 is 4, and 8 times 1/2 is 4, so '
          'they cancel. It takes the two levers together to climb.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
