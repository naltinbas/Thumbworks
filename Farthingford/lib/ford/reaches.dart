import 'reach.dart';

/// The five reaches that ship.
///
/// Every number here is checked twice before the bake: the walk
/// takes each reach to its landing, the sweep reads every ford of
/// the stream, and tool/check_reaches.dart refuses the lot if
/// anything disagrees.
class Reaches {
  static const all = [
    Reach(
      name: 'The First Ford',
      target: (1, 2),
      wades: 1,
      note: 'The first mediant of the whole stream is the half: '
          'one and one over one and one, the only ford of depth '
          'two there is.',
    ),
    Reach(
      name: 'The Three Fifths',
      target: (3, 5),
      wades: 3,
      note: 'Right, then left: each wade keeps the target between '
          'the banks, and the third mediant lands it.',
    ),
    Reach(
      name: 'The Three Sevenths',
      target: (3, 7),
      wades: 4,
      note: 'The stone before the landing is two fifths, and its '
          'circle kisses the half\'s: their crossing number is one, '
          'as it is for every pair of banks the wade ever holds.',
    ),
    Reach(
      name: 'The Three Eighths',
      target: (3, 8),
      wades: 4,
      note: 'Depth eight in four wades: the wade is the continued '
          'fraction of the target, walked one letter at a time.',
    ),
    Reach(
      name: 'The Shallow Ford',
      startA: (1, 2),
      startC: (2, 3),
      shallowerThan: 5,
      wades: null,
      note: 'Between the half and the two thirds the mediant is '
          'three fifths, and no crossing runs shallower: for any '
          'ford between two neighbouring banks, the depth is at '
          'least the banks\' depths put together.',
    ),
  ];

  static int get count => all.length;

  static Reach at(int number) => all[number];
}
