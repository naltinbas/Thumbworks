import 'crossing.dart';

/// The five crossings that ship.
///
/// Every number here is checked before the bake: every crossing
/// walked, the arithmetic held to it, and tool/check_planks.dart
/// refuses the lot if anything disagrees.
class Crossings {
  static const all = [
    Crossing(
      name: 'The One and One',
      sheep: 1,
      goats: 1,
      jumps: true,
      moves: 3,
      ways: 2,
      note: 'One jump and two steps, three moves, and two crossings: '
          'the sheep steps first or the goat does.',
    ),
    Crossing(
      name: 'The Two and Two',
      sheep: 2,
      goats: 2,
      jumps: true,
      moves: 8,
      ways: 2,
      note: 'Four jumps and four steps, eight moves, two crossings that '
          'are mirrors of one another; twenty-three planks can be '
          'reached in all, and most of them are stuck.',
    ),
    Crossing(
      name: 'The Three and Two',
      sheep: 3,
      goats: 2,
      jumps: true,
      moves: 11,
      ways: 2,
      note: 'Six jumps and five steps, eleven moves, and two crossings, '
          'though the flock is uneven; forty planks can be reached.',
    ),
    Crossing(
      name: 'The Three and Three',
      sheep: 3,
      goats: 3,
      jumps: true,
      moves: 15,
      ways: 2,
      note: 'Lucas\'s puzzle: nine jumps and six steps, fifteen moves, '
          'two crossings, and seventy-two planks reachable, seventy of '
          'them on the way or stuck.',
    ),
    Crossing(
      name: 'The Steps Alone',
      sheep: 2,
      goats: 2,
      jumps: false,
      moves: 0,
      ways: 0,
      note: 'Steps keep every beast behind the one in front, so the order '
          'along the plank stays sheep, sheep, goat, goat for ever; only '
          'five planks can be reached, and the fold is stuck in two moves.',
    ),
  ];

  static int get count => all.length;

  static Crossing at(int number) => all[number];
}
