import 'level.dart';

/// The five boards that ship.
///
/// Every number here is checked before the bake: the sweep of every
/// setting, the diagonals counted against it, and
/// tool/check_mitres.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Three',
      side: 3,
      bishops: 4,
      ways: 8,
      settings: 126,
      note: 'Four bishops on nine squares, 126 ways to set them and 8 with no '
          'clash: the five rising diagonals hold one bishop apiece at most, '
          'and the two corner ones, single squares, share the long falling '
          'diagonal, so four is the most.',
    ),
    Level(
      name: 'The Four',
      side: 4,
      bishops: 6,
      ways: 16,
      settings: 8008,
      note: 'Six on sixteen squares: 8,008 settings, 16 peaceful, and every '
          'one of the 16 uses six of the seven rising diagonals and only '
          'squares round the edge. A bishop in the middle four kills it: it '
          'takes the long falling diagonal, and both lonely corners with it.',
    ),
    Level(
      name: 'The Five',
      side: 5,
      bishops: 8,
      ways: 32,
      settings: 1081575,
      note: 'Eight bishops, 1,081,575 settings and 32 peaceful; the count of '
          'peaceful settings of two less than twice the side doubles with '
          'every side, 4, 8, 16, 32, 64, 128 from two to seven, read off '
          'diagonal by diagonal.',
    ),
    Level(
      name: 'The Held Corner',
      side: 4,
      bishops: 6,
      given: [(0, 0)],
      ways: 8,
      settings: 3003,
      note: 'A bishop held in the top left corner takes the long falling '
          'diagonal, so the far corner is barred, and 8 of the 3,003 settings '
          'of the other five stand peaceful, half of the sixteen.',
    ),
    Level(
      name: 'The Seven',
      side: 4,
      bishops: 7,
      ways: 0,
      settings: 11440,
      note: 'Seven rising diagonals, one bishop apiece at most, so seven '
          'bishops would need one on every rising diagonal, the two corner '
          'squares among them; but those two corners share the long falling '
          'diagonal, and clash. None of the 11,440 settings is peaceful.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
