import 'moor.dart';

/// The moors that ship.
///
/// Four teaches with exactly two settings, mirror images of each other.
/// Six is the spiky one, seven hundred and twenty ways to place six
/// mills in six files and only four of them windproof. The Three Mills
/// cannot be set at all, and the why walks the cases by hand. Eight is
/// the classic, ninety two ways among four billion placements.
class Moors {
  const Moors._();

  static final List<Moor> all = [
    Moor(
      name: 'The Four Mills',
      size: 4,
      possible: true,
      ways: 2,
      note: 'Two settings, and they are each other\'s mirror. Neither '
          'uses a corner: on this moor the corners are traps.',
    ),
    Moor(name: 'The Five Mills', size: 5, possible: true, ways: 10),
    Moor(
      name: 'The Three Mills',
      size: 3,
      possible: false,
      ways: 0,
      note: 'Walk the cases: a mill in the middle plot sees every other '
          'plot, so the middle stays empty. The three plots of the top '
          'row see every plot of the middle row except the one each '
          'slants past, and whichever corner or edge you work from, the '
          'third mill finds every plot taken. Nine plots, and no three '
          'keep the wind.',
    ),
    Moor(
      name: 'The Six Mills',
      size: 6,
      possible: true,
      ways: 4,
      note: 'Only four settings on the whole moor, the fewest of any '
          'size past three: six is the spiky one, and the plain '
          'staircase of odd rows then even trips on it nowhere, which '
          'is its own small miracle of the remainder rules.',
    ),
    Moor(name: 'The Eight Mills', size: 8, possible: true, ways: 92),
  ];

  static int get count => all.length;

  static Moor at(int number) => all[number.clamp(0, all.length - 1)];
}
