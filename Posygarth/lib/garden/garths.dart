import 'garth.dart';

/// The garths that ship.
///
/// Three, four and five bloom, and the plantings that prove it are two
/// lines of arithmetic or one doubled square. The Pair of Pairs cannot
/// bloom at all, and the sweep of every attempt fits in a blink. Six is
/// the famous refusal, Euler's officers, and it does not ship: too large
/// to sweep honestly on a phone, and this shelf does not assert what it
/// has not checked.
class Garths {
  const Garths._();

  static final List<Garth> all = [
    Garth(
      name: 'The Three Beds',
      size: 3,
      possible: true,
      note: 'The planting is two lines: bed r,c takes flower r plus c '
          'and colour r plus twice c, wrapped. Odd garths all yield to '
          'it.',
    ),
    Garth(
      name: 'The Four Beds',
      size: 4,
      possible: true,
      note: 'Four resists the two-line planting and yields to the '
          'doubling trick instead: a known square, baked and checked.',
    ),
    Garth(
      name: 'The Pair of Pairs',
      size: 2,
      possible: false,
      note: 'Two flowers, two colours, four beds. Each row must hold '
          'both flowers and both colours, so the second row is the '
          'first turned round, and the pairings double: try every way, '
          'there are few, and every one repeats a posy. No garth of two '
          'exists.',
    ),
    Garth(name: 'The Five Beds', size: 5, possible: true),
    Garth(
      name: 'The Seeded Five',
      size: 5,
      possible: true,
      seeded: [
        for (var column = 0; column < 5; column++)
          (column, column, (2 * column) % 5),
      ],
      note: 'The top row is planted for you, straight from the two-line '
          'arithmetic. The rest must honour it.',
    ),
  ];

  static int get count => all.length;

  static Garth at(int number) => all[number.clamp(0, all.length - 1)];
}
