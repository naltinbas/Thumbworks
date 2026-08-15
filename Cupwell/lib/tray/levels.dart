import 'level.dart';

/// The five trays that ship.
///
/// Every number here is checked before the bake: every sequence swept,
/// the reach walked, the parity law held to it, and
/// tool/check_flips.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Two of Three',
      cups: 3,
      each: 2,
      down: 0x3,
      turns: 1,
      ways: 1,
      sequences: 3,
      note: 'Two cups down of three, and two turn over at a time: turn the '
          'two that are down, one turn of the three possible. Turning by twos '
          'never changes whether the count down is odd or even, and two is '
          'even like nought.',
    ),
    Level(
      name: 'The Four by Three',
      cups: 4,
      each: 3,
      down: 0xF,
      turns: 4,
      ways: 24,
      sequences: 256,
      note: 'Four down, three at a time: every turn leaves an odd count of '
          'cups changed, and four turns are the fewest that bring all four '
          'up, 24 sequences of the 256; every one of the sixteen trays can '
          'be reached from every other by threes.',
    ),
    Level(
      name: 'The Five by Three',
      cups: 5,
      each: 3,
      down: 0x1F,
      turns: 3,
      ways: 60,
      sequences: 1000,
      note: 'Five down, three at a time, three turns: 60 of the 1,000 '
          'sequences right the tray, and by threes every one of the 32 trays '
          'is within reach.',
    ),
    Level(
      name: 'The Six by Four',
      cups: 6,
      each: 4,
      down: 0x3F,
      turns: 3,
      ways: 120,
      sequences: 3375,
      note: 'Six down, four at a time, three turns: 120 of the 3,375 '
          'sequences right the tray. Fours keep the count down even, so only '
          '32 of the 64 trays are ever reached, the even ones, and all up is '
          'among them.',
    ),
    Level(
      name: 'The One of Three',
      cups: 3,
      each: 2,
      down: 0x1,
      turns: 6,
      ways: 0,
      sequences: 729,
      note: 'One cup down of three, two turned at a time. A turn of two '
          'changes the count down by two, or by nought when one goes up as '
          'the other goes down, so an odd count stays odd for ever, and all '
          'up is even. Four trays are reachable of the eight, all with an '
          'odd count down.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
