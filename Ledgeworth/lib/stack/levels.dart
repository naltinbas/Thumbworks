import 'level.dart';

/// The five stacks that ship.
///
/// Every number here is checked before the bake: every stack on the
/// grid swept for standing and reach, the harmonic stack held to it,
/// and tool/check_stacks.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The One',
      books: 1,
      asked: 12,
      ways: 1,
      stacks: 25,
      note: 'One book stands on the desk while its middle is over the desk, '
          'so half of it can hang out and no more: of the 25 places on the '
          'grid, one reaches half, and the twenty-fourth past it topples.',
    ),
    Level(
      name: 'The Two',
      books: 2,
      asked: 18,
      ways: 1,
      stacks: 625,
      note: 'The top book hangs half over the one below, and the two together '
          'weigh from a quarter behind the lower book\'s edge, so the lower '
          'book hangs a quarter over the desk: three quarters in all, and one '
          'stack of the 625 on the grid reaches it.',
    ),
    Level(
      name: 'The Four',
      books: 4,
      asked: 24,
      ways: 16,
      stacks: 390625,
      note: 'Half, a quarter, a sixth and an eighth: 1 + 1/2 + 1/3 + 1/4 over '
          'two is 25/24, so four books can hang the top one a whole book out '
          'and a twenty-fourth past it. Sixteen stacks of the 390,625 on the '
          'grid reach a whole book, and one reaches the twenty-fourth past.',
    ),
    Level(
      name: 'The Five',
      books: 5,
      asked: 27,
      ways: 4,
      stacks: 9765625,
      note: 'The harmonic stack of five hangs out 137/120 of a book, and on '
          'the twenty-fourths that is 27 and a fraction; four stacks of the '
          '9,765,625 on the grid reach 27, and none reaches 28.',
    ),
    Level(
      name: 'The Three',
      books: 3,
      asked: 24,
      ways: 0,
      stacks: 15625,
      note: 'Half, a quarter and a sixth make eleven twelfths, and that is the '
          'best three books can do, each resting on the one below: the sweep '
          'of all 15,625 stacks on the grid finds 22 twenty-fourths at the '
          'most, one stack reaching it, and a whole book is two more.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
