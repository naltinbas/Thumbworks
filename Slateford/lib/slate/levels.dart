import 'level.dart';
import 'rules.dart';

/// The five slates that ship.
///
/// Every number here is checked before the bake: every game against
/// the book walked from every start, the tree's word held to the
/// book's, and tool/check_slates.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Open Slate',
      start: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      side: Rules.cross,
      win: false,
      from: 'from the open slate',
      ways: 111,
      games: 457,
      note: 'Whatever corner or side you open, the book takes the middle; '
          'open in the middle and it takes a corner. From there 457 games '
          'can be played against it and 111 of them end level; the tree '
          'reads the open slate as level for both sides.',
    ),
    Level(
      name: 'The Second Hand',
      start: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      side: Rules.nought,
      win: false,
      from: 'against the book\'s opening',
      ways: 16,
      games: 140,
      note: 'The book opens in the middle. A nought in any corner keeps the '
          'slate level; a nought on any side loses it, since a cross in the '
          'far corner then makes two threats at once. Sixteen of the 140 '
          'games from here end level.',
    ),
    Level(
      name: 'The Corner Trap',
      start: [1, 0, 0, 2, 0, 0, 0, 0, 0],
      side: Rules.cross,
      win: true,
      from: 'from a corner against a side',
      ways: 5,
      games: 81,
      note: 'A cross in the corner answered by a nought on the side is '
          'already lost for the noughts: the tree reads it as a forced win, '
          'and 5 of the 81 games against the book take it, all by a fork.',
    ),
    Level(
      name: 'The Two Corners',
      start: [1, 0, 0, 0, 2, 0, 0, 0, 1],
      side: Rules.nought,
      win: false,
      from: 'between two corner crosses',
      ways: 4,
      games: 28,
      note: 'Two crosses in opposite corners round your nought in the middle: '
          'a nought in a corner now loses to a fork, and only the four sides '
          'keep the slate level, 4 games of the 28.',
    ),
    Level(
      name: 'The Cross Wins',
      start: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      side: Rules.cross,
      win: true,
      from: 'from the open slate',
      ways: 0,
      games: 457,
      note: 'The book never searches: it wins if it can, blocks a threat, '
          'blocks a fork, takes the middle, and so on down eight rules; '
          'against every one of the 457 games from your nine openings it '
          'holds the slate level or better, and the tree agrees that no '
          'opening forces a win.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
