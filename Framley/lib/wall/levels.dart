import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const nine = [18, 15, 14, 10, 9, 8, 7, 4, 1];
  static const otherNine = [36, 33, 28, 25, 16, 9, 7, 5, 2];
  static const ten = [25, 24, 23, 22, 19, 17, 11, 6, 5, 3];

  static const all = [
    Level(
      name: 'The Last Five',
      width: 32,
      height: 33,
      sizes: nine,
      fixed: {18: (0, 0), 15: (0, 18), 14: (18, 0), 10: (22, 14)},
      ways: 1,
      note: 'With the 18, the 15, the 14 and the 10 hung, the last five go one '
          'way only: the 4 under the 14, the 7 beside the 15, then the 1, the 9 '
          'and the 8 in the corner that is left, 1,056 cells filled exactly.',
    ),
    Level(
      name: 'The Nine',
      width: 32,
      height: 33,
      sizes: nine,
      ways: 4,
      note: 'Moron\'s rectangle of 1925, the smallest wall of nine: four '
          'hangings fill it, and they are one hanging turned and mirrored; '
          'the 1 hangs walled in by the 7, the 8, the 9 and the 10, and the '
          'areas add to 1,056, thirty-two by thirty-three.',
    ),
    Level(
      name: 'The Other Nine',
      width: 61,
      height: 69,
      sizes: otherNine,
      ways: 4,
      note: 'The other wall of nine, sixty-one by sixty-nine: four hangings, '
          'one but for turning and mirroring, the 2 walled in by the 5, the 7, '
          'the 9 and the 36, and 4,209 cells filled.',
    ),
    Level(
      name: 'The Ten',
      width: 47,
      height: 65,
      sizes: ten,
      ways: 4,
      note: 'Ten frames, 3 to 25, on forty-seven by sixty-five: four hangings, '
          'one but for turning and mirroring, the 3 walled in by the 11, the '
          '19, the 22 and the 25, and 3,055 cells filled.',
    ),
    Level(
      name: 'The One on the Rim',
      width: 32,
      height: 33,
      sizes: nine,
      smallestOnRim: true,
      ways: 0,
      note: 'The 1 on the rim has a taller frame on either side along the '
          'edge, or one and the wall\'s corner, so it sits at the bottom of a '
          'well one cell wide, and whatever covers the cell above it must be '
          'one cell wide too, and no other frame is: of the four hangings of '
          'the wall none has the 1 on the rim, and the search with the 1 held '
          'to the rim finds nothing.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
