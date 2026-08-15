import 'level.dart';

/// The five patterns that ship.
///
/// Every number here is checked before the bake: every pack of four,
/// six and eight cards walked from all face down, Hummer's count held
/// on every pack reached, every sequence of moves swept for the sham,
/// and tool/check_turnings.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Top Two',
      cards: 4,
      pattern: [true, true, false, false],
      moves: 1,
      ways: 1,
      sequences: 2,
      note: 'One turn does it: the top two turned over as one, one at an even '
          'place and one at an odd. Of the two sequences of one move, the turn '
          'lands and the cut does not.',
    ),
    Level(
      name: 'The Ends',
      cards: 4,
      pattern: [true, false, false, true],
      moves: 2,
      ways: 1,
      sequences: 4,
      note: 'Turn, then cut: the two turned up are parted, one to the bottom, '
          'and the ends of the pack lie up, one at an even place and one at an '
          'odd. One sequence of the four of two moves.',
    ),
    Level(
      name: 'The Middle Two',
      cards: 4,
      pattern: [false, true, true, false],
      moves: 4,
      ways: 1,
      sequences: 16,
      note: 'Four moves at the fewest, one sequence of the sixteen: turn, cut, '
          'cut, cut, and the two turned up have travelled to the middle.',
    ),
    Level(
      name: 'All Four Up',
      cards: 4,
      pattern: [true, true, true, true],
      moves: 4,
      ways: 1,
      sequences: 16,
      note: 'Turn, cut, cut, turn: two up, moved under, and the other two '
          'turned up over them, four moves and one sequence of the sixteen; '
          'every card up is two at even places and two at odd, as it must be.',
    ),
    Level(
      name: 'One Card Up',
      cards: 4,
      pattern: [true, false, false, false],
      moves: 6,
      ways: 0,
      sequences: 64,
      note: 'The top two lie at an even place and an odd, and turned over as one '
          'they swap, so the count of cards up at even places and the count at '
          'odd move together; a cut sends every card to a place of the other '
          'kind and swaps the two counts. They start nought and nought and stay '
          'equal for ever, and one card up is one against nought: of the 48 packs '
          'the walk reaches, none has one card up, and of the 64 sequences of six '
          'moves none lands.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
