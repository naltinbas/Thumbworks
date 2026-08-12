import 'bench.dart';

/// The five benches that ship.
///
/// Every number here is checked twice before the bake: the sweep
/// recuts every pair of every bench, the factor-trade builds them
/// again from the other side, and tool/check_benches.dart refuses
/// the lot if anything disagrees.
class Benches {
  static const all = [
    Bench(
      name: 'The Little Pair',
      facesOne: 4,
      facesTwo: 4,
      ways: 2,
      note: 'The four-siders trade as the six-siders do, and every '
          'die of every matching pair keeps exactly one ace: the '
          'lone factor of x sees to that.',
    ),
    Bench(
      name: 'The Other Bones',
      facesOne: 6,
      facesTwo: 6,
      ways: 2,
      note: 'The other pair runs 1 2 2 3 3 4 against 1 3 4 5 6 8: '
          'totals of fifteen and twenty-seven where the standard '
          'pair carries twenty-one each, and no face past eight.',
    ),
    Bench(
      name: 'The Faithful Partner',
      facesOne: 6,
      facesTwo: 6,
      lockedOne: true,
      otherThanStandard: false,
      ways: 1,
      note: 'A standard die has one partner and it is its own twin: '
          'the sweep of every second die finds exactly the one.',
    ),
    Bench(
      name: 'The Long and the Short',
      facesOne: 4,
      facesTwo: 6,
      ways: 4,
      note: 'Four pairs fall alike here, the standard and three '
          'strangers, and one of the strangers is the little '
          'pair\'s own 1 2 2 3 with a stretched partner.',
    ),
    Bench(
      name: 'The Even Bones',
      facesOne: 6,
      facesTwo: 6,
      evensOnly: true,
      otherThanStandard: false,
      ways: 0,
      note: 'Three is on the standard table and three is odd; two '
          'even pips only ever make even. The sweep of every '
          'even-pipped pair, all 3,570 of them, finds none.',
    ),
  ];

  static int get count => all.length;

  static Bench at(int number) => all[number];
}
