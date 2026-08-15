import 'level.dart';

/// The five crews that ship.
///
/// Every number here is checked before the bake: every division of the
/// gold swept for every crew, the votes reckoned from the crew one
/// smaller, and tool/check_plans.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'Two Pirates',
      pirates: 2,
      keep: 10,
      ways: 1,
      plans: 1,
      note: 'Two aboard and one aye is half: the captain votes for himself and '
          'keeps all ten, and the second pirate, who would keep all ten were '
          'the captain gone, gets nothing and cannot stop it.',
    ),
    Level(
      name: 'Three Pirates',
      pirates: 3,
      keep: 9,
      ways: 1,
      plans: 3,
      note: 'Three aboard need two ayes. The second pirate expects all ten with '
          'the captain gone, so no coin buys him; the third expects nothing, so '
          'one coin buys his aye: nine, nought, one, and one plan of the three '
          'keeping nine passes.',
    ),
    Level(
      name: 'Four Pirates',
      pirates: 4,
      keep: 9,
      ways: 1,
      plans: 4,
      note: 'Four aboard need two ayes, the captain\'s and one more. With the '
          'captain gone the second keeps nine, the third nothing and the fourth '
          'one, so the third is bought for one coin: nine, nought, one, nought.',
    ),
    Level(
      name: 'Five Pirates',
      pirates: 5,
      keep: 8,
      ways: 1,
      plans: 15,
      note: 'Five aboard need three ayes. With the captain gone the second '
          'keeps nine, the third nothing, the fourth one, the fifth nothing, so '
          'the third and the fifth are bought for a coin each: eight, nought, '
          'one, nought, one, the old answer, and one plan of the fifteen keeping '
          'eight passes.',
    ),
    Level(
      name: 'The Greedy Captain',
      pirates: 5,
      keep: 9,
      ways: 0,
      plans: 5,
      note: 'To keep nine the captain has one coin to give and needs two more '
          'ayes; the second pirate expects nine, the third nothing, the fourth '
          'one, the fifth nothing, and one coin buys one aye and never two. Of '
          'the five plans keeping nine, every one goes down.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
