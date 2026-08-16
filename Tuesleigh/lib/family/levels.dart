import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Third',
      kind: 'exactly',
      chance: (1, 3),
      ways: 1,
      note: 'One tag is no tag at all: told only that one of the two is a '
          'boy, three families of the four have one, boy and boy, boy and '
          'girl, girl and boy, and one of the three has two boys, a third. '
          'Told which child is the boy, the elder say, the other is a boy '
          'half the time. Only one tag gives a third; two give 3/7, three '
          '5/11.',
    ),
    Level(
      name: 'The Nine in Nineteen',
      kind: 'exactly',
      chance: (9, 19),
      ways: 1,
      note: 'Five tags, a boy born on one of five working days: each child '
          'is one of ten kinds, a hundred families alike, nineteen of them '
          'with a boy of the first tag, ten with him as the elder and ten '
          'with him as the younger less the one counted twice, and nine of '
          'the nineteen are two boys. Only five tags give 9/19.',
    ),
    Level(
      name: 'The Tuesday Boy',
      kind: 'exactly',
      chance: (13, 27),
      ways: 1,
      note: 'Seven tags, a boy born on a Tuesday: fourteen kinds of child, '
          '196 families, twenty-seven with a Tuesday boy, and thirteen of '
          'those with two boys, 13/27, nearer a half than the third the bare '
          'telling gives, since a Tuesday boy is a rarer thing to have and '
          'two boys are more ways to have one. Only seven tags give 13/27.',
    ),
    Level(
      name: 'The Nearer Half',
      kind: 'atLeast',
      chance: (49, 100),
      ways: 18,
      note: 'The more tags, the nearer a half: thirteen tags give 25/51, past '
          '49 in a hundred, and every count from thirteen to thirty does, '
          'eighteen of the 30, thirty giving 59/119. Three hundred and '
          'sixty-five tags, a birthday, would give 729/1,459, short of a half '
          'by one part in 2,918.',
    ),
    Level(
      name: 'The Half',
      kind: 'half',
      ways: 0,
      note: 'Hopeless, and the tile says so. With k tags the families holding '
          'a boy of the first tag number 4k - 1, and those of two boys among '
          'them 2k - 1; twice 2k - 1 is 4k - 2, one short of 4k - 1, so the '
          'chance is a half less one part in twice 4k - 1, 1/6 short at one '
          'tag, 1/54 at seven and 1/238 at thirty, and never a half. Told '
          'which child is the tagged boy, the chance is exactly a half at '
          'every tag count.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
