import 'moor.dart';

/// The five moors that ship.
///
/// Every number here is checked before the bake: the sum census
/// and the pruned sweep, and tool/check_moors.dart refuses the
/// lot if anything disagrees.
class Moors {
  static const all = [
    Moor(
      name: 'The Four',
      stones: 4,
      paints: 2,
      ways: 2,
      note: 'Two paints carry four stones exactly two ways, each '
          'the other\'s swap: 1 and 4 in one paint, 2 and 3 in '
          'the other. A fifth stone kills both, which is '
          'Schur\'s first wall.',
    ),
    Moor(
      name: 'The Eight',
      stones: 8,
      paints: 3,
      ways: 288,
      note: 'Three paints leave room at eight stones: 288 clean '
          'paintings of the 6,561 there are.',
    ),
    Moor(
      name: 'The Eleven',
      stones: 11,
      paints: 3,
      ways: 186,
      note: 'The field thins as the row grows: 186 paintings '
          'survive at eleven stones, fewer than at eight though '
          'the choices multiply.',
    ),
    Moor(
      name: 'The Thirteen',
      stones: 13,
      paints: 3,
      ways: 18,
      note: 'Schur\'s second wall stands at thirteen: eighteen '
          'paintings of the 1,594,323 possible survive, and not '
          'one of them stretches a stone further.',
    ),
    Moor(
      name: 'The Fourteenth Stone',
      stones: 14,
      paints: 3,
      ways: 0,
      note: 'The sweep walked every painting of fourteen stones '
          'with the bad sums pruned as it went, and nothing '
          'survives: three paints end at thirteen, exactly where '
          'Schur said they would.',
    ),
  ];

  static int get count => all.length;

  static Moor at(int number) => all[number];
}
