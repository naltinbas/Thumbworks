import 'level.dart';
import 'rules.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Overbid Loss',
      kind: 'overbid',
      ring: Rules.sealed,
      ways: 286,
      aim: (10, 12, 11),
      note: '286 settings of the 2,197 have you bidding over the beast\'s '
          'worth, taking it, and paying more than it was worth. Every one of '
          'them has the best rival bid sitting at or above your worth and '
          'under your bid, which is the only place the extra bid buys you '
          'anything at all, and everything it buys there is a loss.',
    ),
    Level(
      name: 'The Windfall',
      kind: 'windfall',
      ring: Rules.sealed,
      ways: 650,
      aim: (10, 12, 9),
      note: '650 settings of the 2,197 win the beast for less than it is '
          'worth. The gain is the worth less the best rival bid, and your own '
          'bid has nothing to do with it beyond winning: raise it or lower it '
          'and the price does not move.',
    ),
    Level(
      name: 'The Sale Passed Up',
      kind: 'passed',
      ring: Rules.sealed,
      ways: 364,
      aim: (12, 11, 11),
      note: '364 settings of the 2,197 have you bidding under the worth and '
          'losing the beast to a rival who bid less than the worth. The '
          'truthful bid would have taken it at that rival\'s price and left '
          'you in pocket, so shading down throws a gain away.',
    ),
    Level(
      name: 'The Shading Gain',
      kind: 'shading',
      ring: Rules.open,
      ways: 286,
      aim: (12, 11, 10),
      note: '286 settings of the 2,197 beat the truthful bid, and every one '
          'of them is in the open ring with a bid under the worth that still '
          'wins. In that ring the truthful bid pays its whole worth away and '
          'earns nothing at all, so anything that wins for less is better. '
          'This is the ring the sealed one was invented to fix.',
    ),
    Level(
      name: 'Outbid the Truth',
      kind: 'beat',
      ring: Rules.sealed,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. In the '
          'sealed ring your own bid never sets the price, only whether you '
          'win. Push it above the worth and the only beasts it wins for you '
          'are ones already bid past their worth, bought at a loss. Pull it '
          'under and the only beasts it loses you are ones you would have '
          'taken under their worth, a gain thrown away. Both ways lose, so '
          'the dial has nowhere better to sit than the worth. All 2,197 '
          'settings of the three dials were run before the sham was built, '
          'and a million more besides.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
