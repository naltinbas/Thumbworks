import 'level.dart';

/// The five boards that ship.
///
/// Every number here is checked before the bake: every setting swept
/// on the small boards and walked on all, the pairing and the one
/// colour held to the sweep on every board from three to eight, and
/// tool/check_settings.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Three by Three',
      size: 3,
      knights: 5,
      ways: 2,
      settings: 126,
      note: 'The middle square is attacked by nothing and attacks nothing, '
          'so a knight always stands there; the eight round the edge are one '
          'ring of knight\'s moves, and a ring of eight seats four, every other '
          'square, two ways round. Two settings of the 126: four pairs and the '
          'middle left over, five.',
    ),
    Level(
      name: 'The Four by Four',
      size: 4,
      knights: 8,
      ways: 6,
      settings: 12870,
      note: 'The sixteen squares pair off as eight knight\'s moves and each '
          'pair holds one knight at most, so eight is the most; six settings '
          'of the 12,870 seat eight, the two colours among them.',
    ),
    Level(
      name: 'The Five by Five',
      size: 5,
      knights: 13,
      ways: 1,
      settings: 5200300,
      note: 'Twenty-five squares, twelve pairs and one square left over, so '
          'thirteen at most, and one setting alone of the 5,200,300 seats '
          'thirteen: the squares of the corners\' colour, every one of them.',
    ),
    Level(
      name: 'The Six by Six',
      size: 6,
      knights: 18,
      ways: 2,
      settings: 9075135300,
      note: 'Eighteen pairs, eighteen knights, and just two settings of the '
          '9,075,135,300 seat them: the light squares, or the dark.',
    ),
    Level(
      name: 'The Nine',
      size: 4,
      knights: 9,
      ways: 0,
      settings: 11440,
      note: 'The sixteen squares pair off as eight knight\'s moves, drawn faint '
          'on the board, and two knights on one pair attack each other, so '
          'nine can never stand: of the 11,440 settings of nine, every one has '
          'a pair with two.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
