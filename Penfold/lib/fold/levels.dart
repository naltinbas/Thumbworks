import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts. The numbers inside the
/// notes are the same sweep's, written out by hand.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two Whistles',
      fold: 'the near fold',
      length: 2,
      ways: 2,
      note: 'Two whistles are enough here, and two of the four calls of that '
          'length do it: left then right, or right then left. One whistle '
          'never does here, since neither of them sends every field to the '
          'same one, and that is the only way a fold is gathered at a single '
          'blow. Of all 65,536 folds, 2,032 have such a whistle.',
    ),
    Level(
      name: 'The Three',
      fold: 'the low fold',
      length: 3,
      ways: 2,
      note: 'Three whistles, and two of the eight calls of three do it. The '
          'left whistle here leaves field 1 where it is and pulls the rest '
          'down one, so blowing it over and over gathers the flock on its '
          'own.',
    ),
    Level(
      name: 'The Five',
      fold: 'the far fold',
      length: 5,
      ways: 1,
      note: 'Five whistles, and only one call of the 32 does it. The right '
          'whistle turns the fold round without ever bringing two sheep '
          'together, so it has to be used to set the flock up for the left '
          'one rather than to gather anything itself.',
    ),
    Level(
      name: 'The Nine',
      fold: 'the long fold',
      length: 9,
      ways: 1,
      note: 'This is Cerny\'s own fold of four fields, and it needs nine '
          'whistles, which is three squared. One call of the 512 does it and '
          'nothing shorter does. Of all 65,536 folds of four fields and two '
          'whistles, none needs more than nine, and 96 of them need exactly '
          'that.',
    ),
    Level(
      name: 'The Turning Fold',
      fold: 'the turning fold',
      length: 0,
      ways: 0,
      note: 'Hopeless, and the card at the end of the ask says so. Both '
          'whistles here send each field to a field of its own, so no two '
          'sheep ever land together: the flock stays four wide however long '
          'you whistle. Cerny\'s test says the same, since the sheep in '
          'fields 1 and 3 can never be brought together.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
