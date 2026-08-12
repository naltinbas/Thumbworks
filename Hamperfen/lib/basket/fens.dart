import 'fen.dart';

/// The five fens that ship.
///
/// Every number here is checked before the bake: the swallow
/// census, the sweep and the shelf weighing, and
/// tool/check_fens.dart refuses the lot if anything disagrees.
class Fens {
  static const all = [
    Fen(
      name: 'The Pair',
      take: 2,
      ways: 55,
      note: 'Two baskets go free 55 ways of the 120 pairs: the '
          'shelf holds more rivalry than swallowing.',
    ),
    Fen(
      name: 'The Three',
      take: 3,
      ways: 64,
      note: 'Three free baskets come 64 ways, the roomiest '
          'asking on the shelf; the room shrinks fast above it.',
    ),
    Fen(
      name: 'The Five',
      take: 5,
      ways: 6,
      note: 'Six families of five go free, and every one is the '
          'middle shelf with one basket handed back: there is '
          'nowhere else left to stand.',
    ),
    Fen(
      name: 'The Six',
      take: 6,
      ways: 1,
      note: 'Sperner\'s ceiling for four herbs, and the family '
          'is unique: the six two-herb baskets, the middle '
          'shelf entire. Nothing else reaches six.',
    ),
    Fen(
      name: 'The Seventh',
      take: 7,
      ways: 0,
      note: 'The shelf weighing bars it: weigh each basket at '
          'twelve over its shelf\'s width and a free picking '
          'never passes twelve, with twelve only for a whole '
          'shelf. Seven baskets weigh at least fourteen '
          'twelfths, and the sweep of all 11,440 families '
          'found none free.',
    ),
  ];

  static int get count => all.length;

  static Fen at(int number) => all[number];
}
