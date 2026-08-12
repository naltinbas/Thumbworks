import 'moor.dart';

/// The moors that ship.
///
/// Every number here is checked twice over: tool/check_moors.dart
/// walks every herding of each and sweeps the differences besides,
/// and refuses the bake on any disagreement.
class Moors {
  static const all = [
    Moor(
      name: 'The Even Herd',
      russet: 2,
      olive: 2,
      slate: 2,
      fewest: 2,
      note: 'Two of each: any two herds share a remainder by three, '
          'and two meetings settle the moor. The walk finds nothing '
          'shorter.',
    ),
    Moor(
      name: 'The Odd One Out',
      russet: 1,
      olive: 4,
      slate: 4,
      fewest: 4,
      note: 'The two fours share their remainder, so the moor can '
          'settle: four meetings, counted against every herding '
          'there is.',
    ),
    Moor(
      name: 'The Fifteen',
      russet: 2,
      olive: 5,
      slate: 8,
      fewest: 5,
      note: 'Two, five and eight all share a remainder by three, '
          'and the moor settles any of three ways: five meetings at '
          'the fewest.',
    ),
    Moor(
      name: 'The Sixteen',
      russet: 3,
      olive: 5,
      slate: 8,
      fewest: 8,
      note: 'Five and eight share a remainder; three shares with '
          'neither. Eight meetings, none to spare, says the walk.',
    ),
    Moor(
      name: 'The Little Mismatch',
      russet: 1,
      olive: 2,
      slate: 3,
      fewest: null,
      note: 'One, two and three: no two herds share a remainder by '
          'three, and a meeting moves every difference by nought or '
          'three. A settled moor needs two herds level at nought, '
          'difference nought exactly, and nought is out of reach. '
          'The walk of every herding agrees: never.',
    ),
    Moor(
      name: 'The Famous Herd',
      russet: 13,
      olive: 15,
      slate: 17,
      fewest: null,
      note: 'The old chestnut: thirteen, fifteen and seventeen. '
          'Their differences leave remainders one and two by three, '
          'and meetings never change that, so no herd ever swallows '
          'the moor. The walk stood on every herding of all '
          'forty five and found no way through.',
    ),
  ];

  static int get count => all.length;

  static Moor at(int number) => all[number];
}
