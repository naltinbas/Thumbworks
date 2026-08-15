import 'level.dart';

/// The five quilts that ship.
///
/// Every number here is checked before the bake: every game against
/// the house walked from every quilt, the mirror held to the tree,
/// and tool/check_quilts.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Two by Six',
      rows: 2,
      cols: 6,
      youFirst: false,
      ways: 7,
      games: 50,
      note: 'Both sides even, so no patch is its own mirror: whatever the '
          'house sews, the patch across the middle is free for you, and '
          'you can never be the one without a move. Sixteen places for a '
          'patch, and 7 of the 50 games against the house are yours.',
    ),
    Level(
      name: 'The Three by Four',
      rows: 3,
      cols: 4,
      youFirst: true,
      ways: 34,
      games: 324,
      note: 'One side odd, so exactly one patch is its own mirror, the two '
          'middle cells; sew it first and the quilt left is even both ways '
          'round the middle, and mirroring wins. Seven of the seventeen '
          'openings win, and 34 of the 324 games do.',
    ),
    Level(
      name: 'The Three by Three',
      rows: 3,
      cols: 3,
      youFirst: false,
      ways: 8,
      games: 10,
      note: 'Both sides odd: no patch is its own mirror and there is no '
          'middle patch to take, so no mirror trick decides it. The tree '
          'alone does: whoever sews first on the three-by-three loses, and '
          '8 of the 10 games against the house are yours.',
    ),
    Level(
      name: 'The Four by Five',
      rows: 4,
      cols: 5,
      youFirst: true,
      ways: 2909,
      games: 64546,
      note: 'Thirty-one places for a patch, and five openings win, the '
          'middle patch among them; after it, the mirror wins every time. '
          '2,909 of the 64,546 games against the house are yours.',
    ),
    Level(
      name: 'The Four by Four',
      rows: 4,
      cols: 4,
      youFirst: true,
      ways: 0,
      games: 3648,
      note: 'You sew first on an even-by-even quilt, and the house sews the '
          'patch across the middle from yours every time. No patch is its '
          'own mirror on such a quilt, so its answer is always free, and it '
          'is never the one left without a move: none of the 3,648 games is '
          'yours, and the tree agrees.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
