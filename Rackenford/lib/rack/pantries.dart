import 'pantry.dart';

/// The five pantries that ship.
///
/// Every number here is checked before the bake: the pruned
/// sweep, the height racking, the one-rack-fewer refusals, and
/// tool/check_racks.dart refuses the lot if anything disagrees.
class Pantries {
  static const all = [
    Pantry(
      name: 'The Six on Three',
      top: 6,
      racks: 3,
      ways: 12,
      note: 'Three racks because one, two and four make a chain '
          'of three: a chain never shares a rack, and three '
          'racks then do for all six jars.',
    ),
    Pantry(
      name: 'The Eight on Four',
      top: 8,
      racks: 4,
      ways: 864,
      note: 'Eight opens the chain of four, one, two, four, '
          'eight, and the ways jump to the hundreds: every '
          'prime picks its rack nearly free.',
    ),
    Pantry(
      name: 'The Ten on Four',
      top: 10,
      racks: 4,
      ways: 2304,
      note: 'Nine and ten come aboard without costing a rack: '
          'neither stretches any divisor chain past four.',
    ),
    Pantry(
      name: 'The Dozen on Four',
      top: 12,
      racks: 4,
      ways: 1728,
      note: 'Two more jars than ten, yet fewer ways: four '
          'chains of four run through the dozen, every one '
          'starting at one, and the squeeze shows in the '
          'count.',
    ),
    Pantry(
      name: 'The Dozen on Three',
      top: 12,
      racks: 3,
      ways: 0,
      note: 'The four chains of four are one, two, four, '
          'eight; one, two, four, twelve; one, two, six, '
          'twelve; and one, three, six, twelve. Any one of '
          'them alone bars three racks.',
    ),
  ];

  static int get count => all.length;

  static Pantry at(int number) => all[number];
}
