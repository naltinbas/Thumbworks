import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Half Lane',
      kind: 'half',
      ways: 200,
      aim: [0, 1, 3, 6, 8, 9],
      note: '200 villages of the 728 have a lane that exactly half the '
          'stringings run along, and every one of them has six lanes or '
          'more: 120 with six, 50 with seven, 30 with eight. Read as wires, '
          'such a lane is one where the rest of the village offers exactly '
          'one ohm the other way round, so the two halve each other.',
    ),
    Level(
      name: 'The Even Ring',
      kind: 'even',
      ways: 38,
      aim: [2, 3, 4, 6, 8, 9],
      note: '38 villages of the 728 give every lane the same share without '
          'giving any lane all of the stringings: the 12 rings that run '
          'through all five greens, at 4/5 a lane; 25 villages of six lanes '
          'at 2/3, which are the 15 pairs of triangles meeting at a green '
          'and the 10 that join two greens to the other three; and the full '
          'skein at 2/5. Five times 4/5, six times 2/3 and ten times 2/5 all '
          'come to four.',
    ),
    Level(
      name: 'The Two Halves',
      kind: 'twohalves',
      ways: 20,
      aim: [0, 1, 3, 4, 6, 8, 9],
      note: '20 villages of the 728 have two lanes or more at a half each, '
          'and every one of them has seven lanes. No village of five greens '
          'gets more than six lanes to a half at once.',
    ),
    Level(
      name: 'The Full Skein',
      kind: 'full',
      ways: 1,
      aim: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      note: 'One village of the 728, with all ten lanes laid. Every lane '
          'looks the same as every other from where it stands, and the '
          'village strings up 125 ways, so each lane takes 50 of them, which '
          'is 2/5. Ten lanes at 2/5 make four.',
    ),
    Level(
      name: 'More Than Four',
      kind: 'more',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. Every '
          'stringing uses four lanes, never more and never fewer, because '
          'four lanes are what it takes to join five greens without a loop. '
          'Add up each lane\'s share of the stringings and you have counted '
          'the lanes of every stringing once each, four apiece, divided by '
          'the number of stringings. So the total is four however the lanes '
          'lie. All 728 villages the board can hold were strung in full '
          'before the sham was built, and every one of them came to four.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
