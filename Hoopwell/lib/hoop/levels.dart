import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Six',
      dark: 3,
      pale: 3,
      lit: 6,
      ways: 686,
      fewest: 4,
      note: '686 of the 1,225 boards with three stones of each colour land '
          'it, which is more than half. Three and three can leave 5, 6 or 7 '
          'lamps and nothing else: 147 boards leave 5, these 686 leave 6, and '
          '392 leave all seven. Five is the floor, and no board of any kind '
          'goes under it.',
    ),
    Level(
      name: 'The Other Six',
      dark: 2,
      pale: 4,
      lit: 6,
      ways: 441,
      fewest: 4,
      note: '441 of the 735 boards with two dark stones and four pale land '
          'it. Two and four have the same floor as three and three, five, '
          'because the floor only looks at how many stones there are in all. '
          'The spread is different though: 147 boards leave 5, 441 leave 6 '
          'and 147 leave all seven.',
    ),
    Level(
      name: 'Every Lamp',
      dark: 3,
      pale: 3,
      lit: 7,
      ways: 392,
      fewest: 4,
      note: '392 of the 1,225 boards light the whole hoop with three stones '
          'of each colour. Six stones between them could not reach seven '
          'lamps by the floor alone, which only promises five, so the top of '
          'the range is not the theorem talking. It is easier than it looks: '
          'nearly a third of the boards do it.',
    ),
    Level(
      name: 'The Floor',
      dark: 2,
      pale: 4,
      lit: 5,
      ways: 147,
      fewest: 4,
      note: '147 of the 735 boards leave exactly five lamps, which is the '
          'fewest two and four can leave. Every one of the 147 turns out to '
          'be the same shape: the dark stones and the pale stones are both '
          'runs at one shared step round the hoop. Vosper proved in 1956 '
          'that they have to be, whenever the lamps land on the floor and '
          'the floor is not the whole hoop less one.',
    ),
    Level(
      name: 'Four Alight',
      dark: 2,
      pale: 4,
      lit: 4,
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Two and '
          'four have a floor of five, and none of the 735 boards gets under '
          'it. The reason is on the board rather than in the sweep: step '
          'round the hoop by the gap between the two dark stones and, seven '
          'being prime, the step visits every hole. The four pale stones lie '
          'in runs along that walk, and the hole one step past the end of '
          'each run lights and holds no pale stone of its own. So the lamps '
          'come to the pale stones plus the runs, which is five at the very '
          'least. Take the hoop to six holes and it falls apart: two dark '
          'and four pale leave four lamps there nine ways over, because a '
          'step of two or three no longer goes round the whole hoop.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
