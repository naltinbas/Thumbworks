import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Five Houses',
      houses: [2, 3, 5, 8, 12],
      walk: 15,
      under: false,
      ways: 1,
      note: 'Five houses, so there is a middle one and the pump belongs at '
          'it: spot 5, and the walking comes to 15. The average of the five '
          'is 6, and standing the pump there costs 16, one more, which is '
          'the whole difference between the middle and the average in a '
          'sentence.',
    ),
    Level(
      name: 'The Six Houses',
      houses: [1, 3, 4, 8, 9, 11],
      walk: 20,
      under: false,
      ways: 5,
      note: 'Six houses, so there are two middle ones, at spots 4 and 8, and '
          'every spot from one to the other does as well as any other: five '
          'spots, all costing 20. Stepping the pump between them trades one '
          'house\'s walk for another\'s and the total does not move.',
    ),
    Level(
      name: 'The Crowded End',
      houses: [2, 2, 3, 9, 9, 9, 10],
      walk: 21,
      under: false,
      ways: 1,
      note: 'Seven houses with four of them bunched at the far end. The '
          'middle house is at spot 9 and the walking there is 21. The '
          'average falls at spot 6, which costs 24: the crowd pulls the '
          'pump to itself, and the average is pulled only part of the way.',
    ),
    Level(
      name: 'The Far Cottage',
      houses: [3, 4, 5, 6, 12],
      walk: 11,
      under: false,
      ways: 1,
      note: 'Four houses together and one cottage away up the lane. The '
          'cottage drags the average from 4.5 to 6 but leaves the middle '
          'house where it was, at spot 5, and that is where the walking is '
          'least: 11. Move the cottage further off and nothing about the '
          'best spot changes.',
    ),
    Level(
      name: 'Beat the Middle',
      houses: [2, 3, 5, 8, 12],
      walk: 15,
      under: true,
      ways: 0,
      note: 'Hopeless, and the card at the end of the ask says so. Step the '
          'pump one spot along and the total changes by the houses at or '
          'behind it less the houses ahead. While more lie ahead the total '
          'falls, and once more lie behind it rises, so the least is where '
          'the counts even out, which is the middle house. Nothing on the '
          'lane goes under 15, and the sham says so as soon as the pump '
          'stands on the least.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
