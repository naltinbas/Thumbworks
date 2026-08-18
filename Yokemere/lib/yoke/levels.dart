import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Middling Pull',
      pull: 42,
      ways: 10,
      fewest: 2,
      note: '10 of the 120 yokings pull exactly 42, which is more than land '
          'on any other figure. The pulls run from 35 to 55 and the middle '
          'of that range is where the yokings crowd.',
    ),
    Level(
      name: 'The Slack Pull',
      pull: 39,
      ways: 7,
      fewest: 1,
      note: '7 of the 120 pull exactly 39, and one of them is a single swap '
          'from the opening. The opening pulls 35, which is the softest '
          'there is, so every ask on the list is a matter of tightening.',
    ),
    Level(
      name: 'The Strong Pull',
      pull: 53,
      ways: 3,
      fewest: 2,
      note: '3 of the 120 pull exactly 53. Near the top the yokings thin '
          'out, because a hard pull wants the strong yoked to the strong '
          'and there are few ways left to arrange that.',
    ),
    Level(
      name: 'The Best Team',
      pull: 55,
      ways: 1,
      fewest: 2,
      note: '1 yoking of the 120 pulls 55, and it is the one that puts the '
          'rows in the same order, strongest with strongest and weakest '
          'with weakest. Nothing pulls harder. That is the rearrangement '
          'inequality, and the reason is a swap: take any team where a '
          'stronger near ox is yoked to a weaker off one than its '
          'neighbour, swap the two, and the pull changes by the near gap '
          'multiplied by the off gap, which is never a loss.',
    ),
    Level(
      name: 'Past the Best',
      pull: 56,
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Any team '
          'that is not in matching order has two places crossed, and '
          'swapping them never softens the pull, so working the crossings '
          'out one at a time walks up to the matching order and cannot '
          'walk past it. That order pulls 55. The sweep agrees on every '
          'one of the 120 yokings, and on 15,876 other pairs of rows '
          'besides.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
