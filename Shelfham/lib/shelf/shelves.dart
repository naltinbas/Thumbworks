import 'shelf.dart';

/// The five shelves that ship.
///
/// Every number here is checked before the bake: the sweep, the
/// recurrence and the reversal, and tool/check_stacks.dart
/// refuses the lot if anything disagrees.
class Shelves {
  static const all = [
    Shelf(
      name: 'The One Step',
      books: 4,
      asked: 1,
      ways: 11,
      note: 'Eleven of the 24 orderings of four carry exactly '
          'one step down, and eleven carry two: the row reads 1, '
          '11, 11, 1, the same forwards as backwards.',
    ),
    Shelf(
      name: 'The Stair Down',
      books: 4,
      asked: 3,
      ways: 1,
      note: 'Three steps down from four books is every gap '
          'stepping, and only the tallest-to-shortest stair '
          'does it: one ordering alone.',
    ),
    Shelf(
      name: 'The Sixty-Six',
      books: 5,
      asked: 2,
      ways: 66,
      note: 'The middle of the row of five is its fattest '
          'entry: 66 of the 120 orderings carry exactly two '
          'steps down.',
    ),
    Shelf(
      name: 'The Twenty-Six',
      books: 5,
      asked: 3,
      ways: 26,
      note: 'Read any three-step shelf of five backwards and it '
          'carries one: the reversal pairs 26 with 26 across '
          'the row 1, 26, 66, 26, 1.',
    ),
    Shelf(
      name: 'The Fourth Step',
      books: 4,
      asked: 4,
      ways: 0,
      note: 'Four books stand over three gaps, and a step down '
          'needs a gap of its own: four steps want a fifth book '
          'nobody owns. The sweep stood all 24 orderings and the '
          'steps never passed three.',
    ),
  ];

  static int get count => all.length;

  static Shelf at(int number) => all[number];
}
