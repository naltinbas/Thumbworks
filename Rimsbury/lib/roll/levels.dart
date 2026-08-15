import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Twice',
      inside: false,
      want: (2, 1),
      ways: 6,
      aim: (3, 3),
      note: 'A roller the size of the hoop turns twice going round it, not '
          'once: it unrolls the hoop\'s rim, one turn, and the trip itself '
          'is another. Six settings of the 72 do it, every pair of equal '
          'coins, and the mark then draws a heart, the cardioid.',
    ),
    Level(
      name: 'The Thrice',
      inside: false,
      want: (3, 1),
      ways: 3,
      aim: (2, 1),
      note: 'Three turns needs a hoop of twice the roller: two turns for '
          'the rim and one for the trip. Three settings of the 72, hoops of '
          'two, four and six with rollers of one, two and three; the mark '
          'touches the hoop twice a trip and its path closes at once.',
    ),
    Level(
      name: 'The Half',
      inside: false,
      want: (3, 2),
      ways: 3,
      aim: (1, 2),
      note: 'One and a half turns needs a hoop of half the roller: half a '
          'turn for the rim and one for the trip. Three settings of the 72, '
          'and the mark, on the hoop at the start, is not on it again until '
          'the second trip is done and three turns are made.',
    ),
    Level(
      name: 'The Inside Once',
      inside: true,
      want: (1, 1),
      ways: 3,
      aim: (2, 1),
      note: 'Inside, the trip counts against the rim: a hoop of twice the '
          'roller gives two turns for the rim, less one for the trip. Three '
          'settings of the 72, and the mark then runs dead straight, back '
          'and forth along a diameter of the hoop, off the line by less '
          'than a thousand-millionth at 3,600 points of the trip.',
    ),
    Level(
      name: 'The Once',
      inside: false,
      want: (1, 1),
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. Round the outside the trip '
          'alone is a turn, before the rim has unrolled anything, so the '
          'turns are one and the hoop over the roller, always more than one: '
          'none of the 72 settings lands it, and the nearest is a hoop of one '
          'with a roller of six, seven sixths of a turn.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
