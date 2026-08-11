import 'town.dart';

/// The towns that ship.
///
/// Every claim here is checked twice over: tool/check_towns.dart counts
/// the odd landings and searches every trail, and refuses the bake on
/// any disagreement.
class Towns {
  static const all = [
    Town(
      name: 'The Mill Round',
      grounds: ['North Bank', 'Mill Isle', 'South Bank', 'Weir Isle'],
      spots: [(0.5, 0.16), (0.84, 0.5), (0.5, 0.84), (0.16, 0.5)],
      bridges: [(0, 1), (1, 2), (2, 3), (3, 0)],
      walkable: true,
      oddGrounds: [],
      note: 'Every landing holds an even count of bridges, so a walk '
          'can start anywhere and comes home to its own door.',
    ),
    Town(
      name: 'The Envelope',
      grounds: [
        'Left Gate',
        'Right Gate',
        'Left Tower',
        'Right Tower',
        'The Spire',
      ],
      spots: [(0.14, 0.82), (0.86, 0.82), (0.14, 0.38), (0.86, 0.38), (0.5, 0.08)],
      bridges: [
        (0, 1),
        (0, 2),
        (1, 3),
        (2, 3),
        (0, 3),
        (1, 2),
        (2, 4),
        (3, 4),
      ],
      // The two diagonals bow apart, so neither hides the other's
      // middle.
      bows: [0, 0, 0, 0, 1.2, 1.2],
      walkable: true,
      oddGrounds: [0, 1],
      note: 'The old one-stroke drawing. The gates hold three bridges '
          'apiece, and every complete walk starts at one gate and ends '
          'at the other: the search counted the walks from every '
          'landing, and from anywhere else there are none.',
    ),
    Town(
      name: 'The Seven Bridges',
      grounds: ['North Bank', 'The Holm', 'East Field', 'South Bank'],
      spots: [(0.42, 0.14), (0.3, 0.5), (0.82, 0.5), (0.42, 0.86)],
      bridges: [
        (0, 1),
        (0, 1),
        (1, 3),
        (1, 3),
        (0, 2),
        (2, 3),
        (1, 2),
      ],
      walkable: false,
      oddGrounds: [0, 1, 2, 3],
      note: 'Old Königsberg, drawn as Euler found it in 1736: the '
          'question that began the study of such maps, and the answer '
          'was no before the first foot fell.',
    ),
    Town(
      name: 'The Eighth Bridge',
      grounds: ['North Bank', 'The Holm', 'East Field', 'South Bank'],
      spots: [(0.42, 0.14), (0.3, 0.5), (0.82, 0.5), (0.42, 0.86)],
      bridges: [
        (0, 1),
        (0, 1),
        (1, 3),
        (1, 3),
        (0, 2),
        (2, 3),
        (1, 2),
        (0, 3),
      ],
      // The new bridge swings west round the Holm rather than running
      // through it.
      bows: [0, 0, 0, 0, 0, 0, 0, 4.6],
      walkable: true,
      oddGrounds: [1, 2],
      note: 'The town mended, as history mended it: one more bridge '
          'between the banks, and two landings turn even. Every '
          'complete walk now runs between the Holm and the East Field, '
          'and the search says so from every start.',
    ),
    Town(
      name: 'The Double Round',
      grounds: [
        'The Green',
        'Fair Field',
        'The Cross',
        'Low Marsh',
        'High Marsh',
      ],
      spots: [(0.18, 0.24), (0.18, 0.72), (0.5, 0.48), (0.82, 0.72), (0.82, 0.24)],
      bridges: [(0, 1), (1, 2), (2, 0), (2, 3), (3, 4), (4, 2)],
      walkable: true,
      oddGrounds: [],
      note: 'Two rounds sharing the Cross, every landing even: a walk '
          'from anywhere, and the Cross is crossed twice on the way.',
    ),
  ];

  static int get count => all.length;

  static Town at(int number) => all[number];
}
