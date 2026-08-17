import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'Past One',
      kind: 'past',
      mark: 1,
      ways: 683,
      aim: (2, 4),
      note: '683 runs of the 1,770 pour more than a barrel. The shortest is '
          'the first two casks, a whole barrel and a half, which comes to '
          '3/2; leave the first cask out and the shortest is a half and a '
          'third and a quarter, 13/12. A run that starts deep in the cellar '
          'has to be a long one, since the casks shrink as fast as their '
          'numbers grow.',
    ),
    Level(
      name: 'Past Two',
      kind: 'past',
      mark: 2,
      ways: 251,
      aim: (1, 4),
      note: '251 runs of the 1,770 pour more than two barrels. The shortest '
          'is the first four casks, a whole and a half and a third and a '
          'quarter, which is 25/12. Leave the first cask out and it takes ten '
          'casks, a 2nd to an 11th, to pass two.',
    ),
    Level(
      name: 'The Halves',
      kind: 'halves',
      mark: 0,
      ways: 1,
      aim: (1, 2),
      note: 'One run of the 1,770 comes out in halves exactly: the first two '
          'casks, a whole and a half, which is 3/2. Every other run leaves a '
          'bottom with more in it than a two, and none of them leaves a '
          'bottom of one.',
    ),
    Level(
      name: 'Past Three',
      kind: 'past',
      mark: 3,
      ways: 90,
      aim: (1, 11),
      note: '90 runs of the 1,770 pour more than three barrels, and the '
          'shortest is the first eleven casks. The total grows like the '
          'logarithm, so the casks a barrel costs keep multiplying: from the '
          'first cask it takes a run to the 2nd to pass a barrel, to the 4th '
          'to pass two, to the 11th to pass three and to the 31st to pass '
          'four, which is twice, then near three times, then near three '
          'times again.',
    ),
    Level(
      name: 'The Whole Barrel',
      kind: 'whole',
      mark: 0,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. Among the '
          'casks of any run there is exactly one with more twos in its '
          'number than any other. Put the run over a common bottom and that '
          'one cask comes out odd on top while every other comes out even, '
          'so the total is odd over even and cannot be whole. The sweep '
          'bears it out: on all 1,770 runs the deepest cask is one and one '
          'only, and every total has an even bottom.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
