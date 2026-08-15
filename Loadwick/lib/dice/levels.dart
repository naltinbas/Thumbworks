import 'level.dart';

/// The five stalls that ship.
///
/// Every number here is checked before the bake: all thirty-six rolls
/// of every pair of the four counted, every die of faces up to six
/// swept against them, and tool/check_dice.dart refuses the lot if
/// anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The House Rolls A',
      house: 0,
      ways: 2,
      picks: 3,
      note: 'A shows four four rolls in six and nought the other two. D shows '
          'five half the time, which beats any A, and one the other half, '
          'which beats A\'s noughts: 24 rolls of 36 to D. C beats A as well, '
          'its sixes always and its twos against the noughts, 20 of 36; B, '
          'showing three, beats only the noughts, 12.',
    ),
    Level(
      name: 'The House Rolls B',
      house: 1,
      ways: 1,
      picks: 3,
      note: 'B shows three every time, so a die beats it exactly as often as it '
          'shows more than three: A four rolls in six, 24 of 36; C two in six, '
          'D three in six, half and no more.',
    ),
    Level(
      name: 'The House Rolls C',
      house: 2,
      ways: 1,
      picks: 3,
      note: 'C shows six twice in six and two the other four. B\'s three beats '
          'every two, 24 rolls of 36; A beats only C\'s twos with its fours, 16; '
          'D beats the twos with its fives, 12.',
    ),
    Level(
      name: 'The House Rolls D',
      house: 3,
      ways: 1,
      picks: 3,
      note: 'D shows five half the time and one the other half. C\'s sixes beat '
          'every D and its twos beat D\'s ones, 12 and 12, 24 of 36; A beats '
          'only the ones, 12; B the ones too, 18, half and no more.',
    ),
    Level(
      name: 'The Champion',
      house: -1,
      ways: 0,
      picks: 4,
      note: 'The four run in a ring: A beats B, B beats C, C beats D and D beats '
          'A, each two rolls in three, so every die loses to the one before it '
          'round the ring, and none beats all the others; C, which beats A too, '
          'still loses to B. Every die of faces up to six was swept against the '
          'four as well: some beat all four, and none of Efron\'s does.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
