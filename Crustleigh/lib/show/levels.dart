import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Ring',
      pies: 3,
      kind: 'ring',
      ways: 12,
      note: 'Twelve of the 216 shows of three pies run in a ring, and they are '
          'exactly the shows whose three ballots are the three turnings of one '
          'ranking, apple bramble cherry, bramble cherry apple, cherry apple '
          'bramble, dealt to the judges six ways, and the ring the other way '
          'round six more; every other show of three has a pie that beats both '
          'others, 204 of 216.',
    ),
    Level(
      name: 'The Ring of Four',
      pies: 4,
      kind: 'ring',
      ways: 720,
      note: 'With four pies 720 of the 13,824 shows run the majority round all '
          'four in a ring, and none of those has a pie beating every other; '
          '1,536 shows have no such pie at all, and 2,352 have some three pies '
          'in a ring.',
    ),
    Level(
      name: 'The Points Betray',
      pies: 4,
      kind: 'points',
      ways: 288,
      note: 'A point for every pie ranked below, summed over the three ballots: '
          'with four pies 288 shows have a pie that beats every other head to '
          'head while another pie has more points; with three pies it never '
          'happens, the pie that beats both others never has fewer points than '
          'either.',
    ),
    Level(
      name: 'The Modest Winner of Four',
      pies: 4,
      kind: 'modest',
      ways: 192,
      note: '192 of the 13,824 shows of four pies have a pie that beats every '
          'other yet is first on no ballot: bramble second on all three, say, '
          'behind apple, cherry and damson in turn, beats each of them two to '
          'one.',
    ),
    Level(
      name: 'The Modest Winner',
      pies: 3,
      kind: 'modest',
      ways: 0,
      note: 'With three pies a pie first on no ballot lies under one of the '
          'other two on each ballot, so the ballots ranking it over apple and '
          'those ranking it over cherry, say, come to three at most between '
          'them, and beating both takes two of each, four: of the 204 shows '
          'with a pie beating both others, that pie is somebody\'s first in all '
          '204, and none of the 216 has a modest winner.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
