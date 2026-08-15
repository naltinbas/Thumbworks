import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Idler',
      width: 7,
      height: 5,
      fixed: [(0, 2, 2), (6, 2, 2)],
      tray: [1],
      kind: 'turns',
      ways: 1,
      settings: 5,
      note: 'The crank and the mill are two units across each and six pegs '
          'apart, and a gear of one on the peg between meshes both, three units '
          'from either peg; it is the only peg of the five it fits that does. '
          'The mill turns the same way as the crank, two meshes on, and once a '
          'turn, since the idler changes nothing but the way.',
    ),
    Level(
      name: 'The Turn Against',
      width: 7,
      height: 5,
      fixed: [(0, 0, 1), (6, 0, 1)],
      tray: [1, 1],
      kind: 'against',
      ways: 1,
      settings: 275,
      note: 'Two gears of one between a crank and a mill of one, six pegs apart '
          'along the bottom: of the 275 ways to peg them, only the pegs two and '
          'four along make a train, and it is four gears long, three meshes, so '
          'the mill turns against the crank.',
    ),
    Level(
      name: 'The Twice',
      width: 7,
      height: 5,
      fixed: [(0, 2, 2), (5, 2, 1)],
      tray: [1],
      kind: 'twice',
      ways: 1,
      settings: 11,
      note: 'A crank of two and a mill of one, five pegs apart, and a gear of one '
          'to set between: the peg three along meshes both, three units from the '
          'crank\'s peg and two from the mill\'s, and the mill turns twice for '
          'every turn of the crank, the crank\'s two over the mill\'s one, the '
          'idler between counting for nothing but the way.',
    ),
    Level(
      name: 'The Ring of Four',
      width: 5,
      height: 5,
      fixed: [(1, 1, 1)],
      tray: [1, 1, 1],
      kind: 'ring',
      ways: 1,
      settings: 159,
      note: 'Three gears of one round a crank of one: of the 159 ways to peg them '
          'one makes a ring, the square two pegs a side, and it turns, the gears '
          'across the square with the crank and the two beside it against, since '
          'a ring of four has an even count.',
    ),
    Level(
      name: 'The Ring of Three',
      width: 5,
      height: 5,
      fixed: [(0, 0, 1)],
      tray: [2, 3],
      kind: 'ring',
      ways: 0,
      settings: 8,
      note: 'A gear of two and a gear of three round a crank of one: the pegs '
          'three along and four up ring them, three, four and five apart, one '
          'and two, one and three, two and three, and so do the pegs the other '
          'way about; but the ring has three gears, and round it the crank would '
          'have to turn both ways, so it jams, and none of the 8 ways to peg the '
          'two turns as a ring.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
