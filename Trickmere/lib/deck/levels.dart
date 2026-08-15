import 'level.dart';

/// The five hands that ship.
///
/// Every number here is checked before the bake: every layout of every
/// hand swept, the assistant's rule held to it, and
/// tool/check_tricks.dart refuses the lot if anything disagrees.
class Levels {
  // Cards: suit times thirteen plus rank less one; clubs 0-12, diamonds
  // 13-25, hearts 26-38, spades 39-51.
  static const all = [
    Level(
      name: 'The Pair of Hearts',
      hand: [27, 47, 17, 12, 32],
      ways: 1,
      layouts: 120,
      note: 'Two hearts, the 2 and the 7, five steps round from the 2 to the '
          '7 and eight the other way; so the 7 is hidden, the 2 shown first, '
          'and the other three laid high, low, middle to tell five. One '
          'layout of the 120.',
    ),
    Level(
      name: 'The Two Pairs',
      hand: [2, 9, 18, 24, 46],
      ways: 2,
      layouts: 120,
      note: 'Two clubs and two diamonds: the 10 of clubs to the 3 is six steps '
          'round, and the 6 of diamonds to the queen is six, so either the 3 or '
          'the queen can be hidden, two layouts of the 120.',
    ),
    Level(
      name: 'The Three Spades',
      hand: [41, 46, 49, 29, 21],
      ways: 3,
      layouts: 120,
      note: 'Three spades, 3, 8 and jack: 3 to 8 is five steps, 8 to jack is '
          'three, jack to 3 is five round the corner, so any of the three can '
          'be hidden with the right mate shown; three layouts of the 120.',
    ),
    Level(
      name: 'The Wrap Round',
      hand: [20, 13, 4, 36, 40],
      ways: 1,
      layouts: 120,
      note: 'The 8 and the ace of diamonds: from the ace to the 8 is seven '
          'steps, too many, but from the 8 round through the king to the ace '
          'is six. So the ace is hidden, the 8 shown first, and the other '
          'three laid high, middle, low to tell six.',
    ),
    Level(
      name: 'The Lone Club',
      hand: [3, 31, 36, 47, 24],
      hiddenFixed: 3,
      ways: 0,
      layouts: 24,
      note: 'The first card laid tells the suit, and no other club is in the '
          'hand to lay; whatever the four say, the partner names a heart, a '
          'spade or a diamond. None of the 24 orders names the 4 of clubs. '
          'Left to choose, the assistant hides the jack of hearts behind the '
          'six.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
