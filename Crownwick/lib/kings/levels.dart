import 'level.dart';

/// The five boards that ship.
///
/// Every number here is checked before the bake: every setting swept
/// on the small boards and walked on all, the blocks and the even
/// squares held to the walk on every board from two to seven, and
/// tool/check_settings.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Three by Three',
      size: 3,
      kings: 4,
      ways: 1,
      settings: 126,
      note: 'Four blocks, the two-by-two in the corner, a two beside it, a two '
          'below and the far corner alone, and one king in each: the four '
          'corners, and no other setting of the 126 seats four.',
    ),
    Level(
      name: 'The Four by Four',
      size: 4,
      kings: 4,
      ways: 79,
      settings: 1820,
      note: 'Four blocks of two-by-two and one king in each, but the blocks '
          'meet along their sides and corners, so not every choice of one '
          'square in each stands: 79 settings of the 1,820 do, of the 256 '
          'that pick one square in each block.',
    ),
    Level(
      name: 'The Five by Five',
      size: 5,
      kings: 9,
      ways: 1,
      settings: 2042975,
      note: 'Nine blocks and nine kings, and one setting alone of the '
          '2,042,975 seats them: the even squares, every other rank and every '
          'other file, since with an odd side each block\'s corner square is '
          'the only one that touches no king in the blocks beyond.',
    ),
    Level(
      name: 'The Six by Six',
      size: 6,
      kings: 9,
      ways: 3600,
      settings: 94143280,
      note: 'Nine blocks of two-by-two, one king in each: 3,600 settings of the '
          '94,143,280 seat nine, sixty squared, the ranks and the files each '
          'chosen sixty ways and free of each other.',
    ),
    Level(
      name: 'The Five',
      size: 4,
      kings: 5,
      ways: 0,
      settings: 4368,
      note: 'The sixteen squares cut into four blocks of two-by-two, drawn faint '
          'on the board, and two kings in one block touch, so five kings on '
          'four blocks put two in one: of the 4,368 settings of five, every one '
          'has a pair that attack.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
