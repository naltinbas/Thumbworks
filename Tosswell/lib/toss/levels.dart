import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'Ahead More Than Half',
      kind: 'half',
      ways: 144,
      aim: [(1, 1)],
      note: '144 rules of the 802 walk away ahead on more than half the runs, '
          'and the cheapest is a single mark: stop the moment the first toss '
          'goes your way. That walks away a shilling up on 16 runs and rides '
          'the other 16 out, ending ahead on 21 of the 32. The purse still '
          'averages nothing, because the runs that go on can go a long way '
          'down.',
    ),
    Level(
      name: 'One Up or One Down',
      kind: 'onedown',
      ways: 1,
      aim: [(1, 1), (1, -1)],
      note: 'One rule of the 802 does it: stop after the first toss, whichever '
          'way it went. Half the runs walk away a shilling up and half a '
          'shilling down, which is the plainest picture of the theorem there '
          'is. Every other rule lets some run reach a purse further from '
          'level than one.',
    ),
    Level(
      name: 'Ahead Two in Three',
      kind: 'twointhree',
      ways: 6,
      aim: [(1, 1), (3, 1)],
      note: '6 rules of the 802 walk away ahead on 22 of the 32 runs, and no '
          'rule does better: 22 in 32 is eleven in sixteen, the most a rule '
          'over five tosses can be ahead. Two marks are enough, stopping a '
          'shilling up after the first toss and again after the third. The '
          'runs that miss both make up for it in size.',
    ),
    Level(
      name: 'Twenty Ahead, Two Down at Worst',
      kind: 'guarded',
      ways: 5,
      aim: [(1, 1), (2, -2), (4, -2)],
      note: '5 rules of the 802 walk away ahead on 20 runs or more while '
          'never going worse than two down. Three marks do it: take a '
          'shilling when the first toss gives it, and cut the loss at two '
          'down after the second toss and again after the fourth. Guarding '
          'the downside costs the upside; the average is nothing either way.',
    ),
    Level(
      name: 'The Sure Thing',
      kind: 'sure',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. Suppose a '
          'rule never walked away behind. Then every run ends at nothing or '
          'better, so the 32 purses added up would be nothing only if every '
          'one of them were nothing, and any run that walked away ahead would '
          'push the total above nothing. But the total is always exactly '
          'nothing: the coin is fair, so at every standing the two tosses '
          'that leave it are worth one more and one less, and averaging back '
          'from the last row to the first leaves the purse where it began. '
          'All 802 rules were walked before the sham was built and every one '
          'of them averaged nothing.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
