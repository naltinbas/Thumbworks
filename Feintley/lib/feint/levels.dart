import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Honest Prime',
      kind: 'honest',
      ways: 308,
      note: 'Every prime passes on every base it does not divide: 196 primes '
          'to 1,200, 28 of them above a thousand, and those 28 pass on all '
          'eleven bases, 308 settings; the primes fail only where the base '
          'is a multiple of them, 2 on 2, 4, 6, 8, 10 and 12, 3 on 3, 6, 9 '
          'and 12, 5 on 5 and 10, and 7 and 11 on themselves, 14 settings '
          'of the 2,156 with a prime.',
    ),
    Level(
      name: 'The Liar of Two',
      kind: 'two',
      ways: 4,
      note: 'Four composites to 1,200 pass on base two: 341, which is 11 '
          'times 31, then 561, 645 and 1,105; the ancient Chinese guess that '
          'passing on two makes a prime fails first at 341, as Sarrus found '
          'in 1819. Base two has the fewest liars of the eleven bases: 116 '
          'liar settings in all, base eight the most with 22.',
    ),
    Level(
      name: 'The Liar of Three',
      kind: 'three',
      ways: 7,
      note: 'Seven composites to 1,200 pass on base three: 91, which is 7 '
          'times 13, then 121, 286, 671, 703, 949 and 1,105; 91 fails on '
          'base two and 341 fails on base three, so a second base catches '
          'most liars, but not all.',
    ),
    Level(
      name: 'The Carmichael',
      kind: 'carmichael',
      ways: 15,
      note: 'Two composites to 1,200 pass on every base they share no factor '
          'with: 561, which is 3 times 11 times 17, on the bases 2, 4, 5, 7, '
          '8 and 10, and 1,105, 5 times 13 times 17, on nine bases; '
          'Carmichael named them in 1910, and there are infinitely many, as '
          'was proved in 1994.',
    ),
    Level(
      name: 'The Failing Prime',
      kind: 'failing',
      ways: 0,
      note: 'Hopeless, and the tile says so. Take a prime p and a base a it '
          'does not divide: the numbers a, 2a, 3a and on to (p - 1)a leave '
          'the remainders 1 to p - 1 by p once each, since two of them '
          'alike would make p divide a difference ka - ja with both k - j '
          'and a too small or too coprime to carry it; so their product is '
          '(p - 1)! times a to the p - 1, and also (p - 1)! itself modulo p, '
          'and a to the p - 1 is one. Fermat wrote it in 1640. The sweep of '
          'all 13,189 settings finds every prime passing on every base it '
          'does not divide, 2,142 settings.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
