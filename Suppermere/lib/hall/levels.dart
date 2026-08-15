import 'level.dart';

/// The five suppers that ship.
///
/// Every number here is checked before the bake: every seating swept,
/// the walk and the odd ring held to the sweep on every quarrel map of
/// five, and tool/check_seatings.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Four Ring',
      guests: 4,
      quarrels: [(0, 1), (1, 2), (2, 3), (0, 3)],
      ways: 2,
      seatings: 16,
      note: 'Four guests round a ring of quarrels: A with B, B with C, C with '
          'D, D with A. Seat A left, then B must sit right, C left, D right, '
          'and D across from A is fine: the ring is even and closes. Two '
          'seatings of the sixteen, this one and its mirror.',
    ),
    Level(
      name: 'The Family',
      guests: 6,
      quarrels: [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5)],
      ways: 2,
      seatings: 64,
      note: 'Quarrels that branch and never ring round: seat any guest, and '
          'every quarreller sits across, and theirs across again, and nothing '
          'ever comes back to clash. Two seatings of the 64, one for each '
          'table A takes.',
    ),
    Level(
      name: 'The Two Rings',
      guests: 8,
      quarrels: [(0, 1), (1, 2), (2, 3), (0, 3), (4, 5), (5, 6), (6, 7), (4, 7)],
      ways: 4,
      seatings: 256,
      note: 'Two parties who never quarrel across, each a ring of four: each '
          'party seats two ways, and the parties are free of each other, so '
          'four seatings of the 256; every supper with no odd ring seats two '
          'ways for each party.',
    ),
    Level(
      name: 'The Cube',
      guests: 8,
      quarrels: [(0, 1), (1, 2), (2, 3), (0, 3), (4, 5), (5, 6), (6, 7), (4, 7), (0, 4), (1, 5), (2, 6), (3, 7)],
      ways: 2,
      seatings: 256,
      note: 'Eight guests and twelve quarrels, the corners and edges of a cube: '
          'every ring of quarrels here is even, four or six or eight round, so '
          'the walk never clashes, and two seatings of the 256 land it.',
    ),
    Level(
      name: 'The Five Ring',
      guests: 5,
      quarrels: [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4)],
      ways: 0,
      seatings: 32,
      note: 'Five round a ring: seat A left, then B right, C left, D right, E '
          'left, and E quarrels with A at the same table. Round an odd ring the '
          'tables must alternate and cannot close, so of the 32 seatings none '
          'keeps every quarrel apart, and every supper with an odd ring of '
          'quarrels is the same.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
