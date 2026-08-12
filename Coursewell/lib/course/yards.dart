import 'yard.dart';

/// The five yards that ship.
///
/// Every number here is checked before the bake: the seam
/// census, the sweep and the crossing count, and
/// tool/check_courses.dart refuses the lot if anything
/// disagrees.
class Yards {
  static const all = [
    Yard(
      name: 'The Four Square',
      width: 4,
      height: 4,
      ways: 36,
      note: 'Every laying of the four-square carries two '
          'seams at least: soundness needs more room than '
          'sixteen cells give.',
    ),
    Yard(
      name: 'The One Seam',
      width: 6,
      height: 6,
      asked: 1,
      ways: 100,
      note: 'One seam is as sound as the six-square ever '
          'lays: no laying of it manages none.',
    ),
    Yard(
      name: 'The Sound Course',
      width: 6,
      height: 5,
      asked: 0,
      ways: 6,
      note: 'Five by six is the smallest yard that lays '
          'sound, two cells wide both ways: of the smaller such '
          'yards, the odd never brick whole and the even were '
          'swept and seamed. The classic, worth finding once '
          'by hand.',
    ),
    Yard(
      name: 'The Seven Seams',
      width: 6,
      height: 6,
      asked: 7,
      ways: 2,
      note: 'Seven seams is the most any six-square laying '
          'carries, and the plain stacks alone wear it: every '
          'brick lying one way, every line their way '
          'unbroken.',
    ),
    Yard(
      name: 'The Seamless Six',
      width: 6,
      height: 6,
      asked: 0,
      ways: 0,
      note: 'The nearest miss is a single seam, worn by a '
          'hundred of the layings; none comes closer.',
    ),
  ];

  static int get count => all.length;

  static Yard at(int number) => all[number];
}
