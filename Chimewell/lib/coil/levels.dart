import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static BigInt _n(int x) => BigInt.from(x);

  static final all = <Level>[
    Level(
      name: 'The Whole Tone',
      want: ('tone', _n(9), _n(8)),
      ways: 1,
      aim: (2, -1),
      note: 'Two fifths up and one octave down: 3/2 times 3/2 is 9/4, and '
          'the octave halves it to 9/8, 203.91 cents. One setting of the '
          '425 sounds it, since 3 and 2 share no factor and a fraction '
          'of them is stacked one way only.',
    ),
    Level(
      name: 'The Third',
      want: ('tone', _n(81), _n(64)),
      ways: 1,
      aim: (4, -2),
      note: 'Four fifths up and two octaves down: 81/64, 407.82 cents, the '
          'third the fifths give. It is sharp of the sweet third 5/4 by '
          '81/80, the other comma, 21.51 cents; no stack of fifths sounds '
          '5/4 itself, since 5 is neither a 2 nor a 3.',
    ),
    Level(
      name: 'The Semitone',
      want: ('tone', _n(256), _n(243)),
      ways: 1,
      aim: (-5, 3),
      note: 'Five fifths down and three octaves up: 256/243, 90.22 cents, '
          'the semitone the fifths give, and it is smaller than the '
          'hundred cents of the piano\'s. Five fifths up and three octaves '
          'down give its mirror, 243/256, 90.22 cents flat.',
    ),
    Level(
      name: 'The Circle',
      want: ('near', _n(1), _n(1)),
      ways: 2,
      aim: (12, -7),
      note: 'Twelve fifths up climb 531,441/4,096, and seven octaves down '
          'leave 531,441/524,288, the comma, 23.46 cents sharp of home; '
          'twelve fifths down and seven octaves up land the mirror, '
          '23.46 cents flat. Those two settings alone come within a '
          'twentieth: five fifths get to 243/256, 13 in 256 short, past '
          'the twentieth, and seven to 2,187/2,048, 139 in 2,048 over.',
    ),
    Level(
      name: 'The Return',
      want: ('home', _n(1), _n(1)),
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. A stack of fifths sounds 3 to '
          'the fifths over 2 to something, and 3 to any power is odd while '
          '2 to any power is even, so the two never match and the note '
          'never comes home: not one of the 425 settings with a fifth in '
          'it lands, and the nearest is the comma.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
