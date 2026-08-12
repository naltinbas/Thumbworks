import 'boxset.dart';

/// The five stacks that ship.
///
/// Every number here is checked before the bake: the sweep turns
/// every box every way, the factoring walks the pencil road, and
/// tool/check_stacks.dart refuses the lot if anything disagrees.
class BoxSets {
  static const all = [
    BoxSet(
      name: 'The Two Boxes',
      boxes: [
        [('R', 'G'), ('R', 'G'), ('R', 'G')],
        [('G', 'R'), ('G', 'R'), ('G', 'R')],
      ],
      opens: [(0, 0, 0, 0), (0, 0, 0, 2)],
      ways: 4,
      note: 'Two boxes, two paints, every sleeve alike: the stack '
          'settles whenever the two disagree wall for wall, and '
          'the sweep counts four such standings.',
    ),
    BoxSet(
      name: 'The Three',
      boxes: [
        [('R', 'G'), ('G', 'B'), ('B', 'R')],
        [('G', 'B'), ('B', 'R'), ('R', 'G')],
        [('B', 'R'), ('R', 'G'), ('G', 'B')],
      ],
      opens: [(0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 0, 0)],
      ways: 48,
      note: 'Three boxes wearing the same three paints in the '
          'same three sleeves, only shifted: 48 of the standings '
          'settle, so the stack forgives a lot here.',
    ),
    BoxSet(
      name: 'The Quads',
      boxes: [
        [('R', 'R'), ('G', 'G'), ('B', 'W')],
        [('R', 'R'), ('G', 'G'), ('B', 'W')],
        [('R', 'R'), ('G', 'G'), ('B', 'W')],
        [('R', 'R'), ('G', 'G'), ('B', 'W')],
      ],
      opens: [
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
      ],
      ways: 96,
      note: 'Four boxes painted exactly alike, and the stack '
          'still settles 96 ways: alike boxes need not stand '
          'alike, which is the whole trick of it.',
    ),
    BoxSet(
      name: 'The Old Four',
      boxes: [
        [('R', 'R'), ('R', 'G'), ('B', 'W')],
        [('R', 'G'), ('G', 'B'), ('W', 'W')],
        [('G', 'W'), ('B', 'R'), ('W', 'R')],
        [('B', 'G'), ('W', 'B'), ('G', 'R')],
      ],
      opens: [
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
      ],
      ways: 24,
      note: 'A four-box stack in the old maddening style: the '
          'sweep finds 24 settlings, and they fall into exactly '
          'three once whole-stack turns and mirrorings are worn '
          'away. The factoring reads the same story in pencil: '
          'five fair picks of sleeves, pairing into three '
          'disjoint pairs.',
    ),
    BoxSet(
      name: 'The Red Stack',
      boxes: [
        [('R', 'R'), ('R', 'R'), ('R', 'G')],
        [('R', 'R'), ('R', 'R'), ('R', 'B')],
        [('R', 'R'), ('G', 'B'), ('W', 'W')],
        [('R', 'G'), ('B', 'W'), ('G', 'B')],
      ],
      opens: [
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
      ],
      ways: 0,
      note: 'Thirteen faces wear red, and a standing stack of '
          'four carries twelve at most: one on each of the four '
          'walls and eight hidden top and bottom. The count dooms '
          'it before a box is turned, the factoring finds no fair '
          'picks to pair, and the sweep of every standing agrees.',
    ),
  ];

  static int get count => all.length;

  static BoxSet at(int number) => all[number];
}
